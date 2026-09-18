-- =============================================================================
-- LiVrai CRM — Schéma PostgreSQL 18 de la refonte
-- Document de référence : docs/architecture-livrai.html (§ 4, Modèle de données)
--
-- Conventions retenues :
--   · snake_case pour les tables et colonnes (convention PostgreSQL)
--   · identifiants BIGINT GENERATED ALWAYS AS IDENTITY (norme SQL, remplace SERIAL)
--   · horodatages TIMESTAMPTZ (fuseau explicite, jamais TIMESTAMP nu)
--   · montants NUMERIC(12,2) — jamais de flottant sur de la monnaie
--   · statuts et rôles en types ENUM — corrige D-14 (VARCHAR français libre)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Types énumérés
-- Corrige D-14 : le statut était un VARCHAR(255) contenant « Acceptée », « En
-- attente »… comparé par égalité de chaînes jusque dans les JSP. Une faute de
-- frappe créait un état invalide silencieux et l'i18n était impossible.
-- Les valeurs sont en anglais, non accentuées : l'affichage est traduit côté
-- front, la donnée ne dépend plus de la langue.
-- -----------------------------------------------------------------------------

CREATE TYPE delivery_status AS ENUM (
    'PENDING',    -- En attente    — créée par le client, non traitée
    'ACCEPTED',   -- Acceptée      — validée par l'exploitation
    'REJECTED',   -- Refusée       — refusée par l'exploitation (cf. UX-06)
    'IN_TRANSIT', -- En cours      — enlevée, en cours d'acheminement
    'DELIVERED',  -- Livrée        — remise effectuée
    'BILLED',     -- Facturée      — facture émise
    'CANCELLED'   -- Annulée       — annulée par le client avant acceptation
);

CREATE TYPE user_role AS ENUM (
    'CLIENT',        -- Entreprise cliente de LiVrai
    'COMMERCIAL',    -- Service commercial : portefeuille clients + facturation
    'EXPLOITATION',  -- Service livraisons : traitement des livraisons + facturation
    'ADMIN'          -- Administration technique : comptes internes et rôles
);

CREATE TYPE invoice_status AS ENUM (
    'DRAFT',    -- Brouillon, modifiable
    'ISSUED',   -- Émise, opposable au client
    'PAID',     -- Réglée
    'CANCELLED' -- Annulée (avoir)
);

-- -----------------------------------------------------------------------------
-- Table : app_user
-- « user » est un mot réservé PostgreSQL (CURRENT_USER) : on le préfixe plutôt
-- que de le mettre entre guillemets à chaque requête.
--
-- Corrige D-05 : password_hash reçoit un hachage BCrypt (60 caractères), jamais
-- le mot de passe. Corrige D-09 : le booléen admin est remplacé par un rôle.
-- -----------------------------------------------------------------------------

CREATE TABLE app_user (
    id              BIGINT       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email           VARCHAR(255) NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    role            user_role    NOT NULL DEFAULT 'CLIENT',
    enabled         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),

    -- Unicité insensible à la casse : Jean@livrai.fr et jean@livrai.fr sont le
    -- même compte. L'ancien UNIQUE simple laissait passer les deux.
    CONSTRAINT uq_app_user_email UNIQUE (email),
    CONSTRAINT ck_app_user_email_format CHECK (email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
    CONSTRAINT ck_app_user_email_lower  CHECK (email = lower(email))
);

COMMENT ON TABLE  app_user IS 'Comptes applicatifs, tous rôles confondus';
COMMENT ON COLUMN app_user.password_hash IS 'Hachage BCrypt — jamais le mot de passe en clair (corrige D-05)';
COMMENT ON COLUMN app_user.enabled IS 'Désactivation logique : on ne supprime pas un compte porteur d''historique';

-- -----------------------------------------------------------------------------
-- Table : customer
-- Entité nouvelle. Dans l'existant, « le client » et « le compte » étaient
-- confondus dans la table user. Or la fiche demande la « gestion des
-- informations du client » et prévoit que plusieurs personnes d'une même
-- entreprise cliente puissent avoir un compte.
-- Séparer l'entreprise (customer) de la personne qui se connecte (app_user)
-- rend cela possible sans dupliquer l'adresse de facturation sur chaque compte.
-- -----------------------------------------------------------------------------

CREATE TABLE customer (
    id                BIGINT       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name      VARCHAR(255) NOT NULL,
    siret             VARCHAR(14),
    contact_email     VARCHAR(255),
    contact_phone     VARCHAR(30),
    billing_street    VARCHAR(255),
    billing_post_code VARCHAR(16),
    billing_city      VARCHAR(100),
    billing_country   CHAR(2)      NOT NULL DEFAULT 'FR',  -- ISO 3166-1 alpha-2
    active            BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT uq_customer_siret  CHECK (siret IS NULL OR siret ~ '^[0-9]{14}$'),
    CONSTRAINT ck_customer_country CHECK (billing_country ~ '^[A-Z]{2}$')
);

CREATE UNIQUE INDEX uq_customer_siret_idx ON customer (siret) WHERE siret IS NOT NULL;

COMMENT ON TABLE customer IS 'Entreprise cliente — distincte des comptes de connexion qui lui sont rattachés';

-- -----------------------------------------------------------------------------
-- Table : customer_account
-- Rattache un compte de connexion à une entreprise cliente.
-- Table d'association : une entreprise peut avoir plusieurs utilisateurs
-- (le gérant, l'assistante logistique…), et le modèle reste ouvert au cas où
-- un utilisateur interviendrait pour plusieurs entités d'un même groupe.
-- -----------------------------------------------------------------------------

CREATE TABLE customer_account (
    customer_id BIGINT      NOT NULL,
    user_id     BIGINT      NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pk_customer_account PRIMARY KEY (customer_id, user_id),
    CONSTRAINT fk_customer_account_customer
        FOREIGN KEY (customer_id) REFERENCES customer (id) ON DELETE CASCADE,
    CONSTRAINT fk_customer_account_user
        FOREIGN KEY (user_id) REFERENCES app_user (id) ON DELETE CASCADE
);

CREATE INDEX idx_customer_account_user ON customer_account (user_id);

-- -----------------------------------------------------------------------------
-- Table : delivery
-- Cœur métier. Reprend volume / weight / status de l'existant (modèle sain,
-- F-03) en corrigeant ce que l'audit a démontré.
--
-- Corrige D-10 : volume et poids acceptaient -99 sans obstacle. Les CHECK
-- rendent l'état invalide impossible au niveau du stockage, indépendamment de
-- la validation applicative.
-- Corrige D-04 : les index portent sur les colonnes réellement filtrées et
-- triées, pas seulement sur la clé étrangère créée d'office.
-- -----------------------------------------------------------------------------

CREATE TABLE delivery (
    id                 BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reference          VARCHAR(20)     NOT NULL,
    customer_id        BIGINT          NOT NULL,
    created_by_user_id BIGINT,
    status             delivery_status NOT NULL DEFAULT 'PENDING',

    volume_m3          NUMERIC(10,3)   NOT NULL,
    weight_kg          NUMERIC(10,3)   NOT NULL,

    pickup_street      VARCHAR(255),
    pickup_post_code   VARCHAR(16),
    pickup_city        VARCHAR(100),
    delivery_street    VARCHAR(255),
    delivery_post_code VARCHAR(16),
    delivery_city      VARCHAR(100),

    requested_pickup_at  TIMESTAMPTZ,
    delivered_at         TIMESTAMPTZ,
    price_ht             NUMERIC(12,2),

    created_at         TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT uq_delivery_reference UNIQUE (reference),
    CONSTRAINT fk_delivery_customer
        FOREIGN KEY (customer_id) REFERENCES customer (id) ON DELETE RESTRICT,
    CONSTRAINT fk_delivery_created_by
        FOREIGN KEY (created_by_user_id) REFERENCES app_user (id) ON DELETE SET NULL,

    -- Corrige D-10 : volume -99 et poids -50 étaient acceptés et facturables.
    CONSTRAINT ck_delivery_volume_positive CHECK (volume_m3  > 0),
    CONSTRAINT ck_delivery_weight_positive CHECK (weight_kg  > 0),
    CONSTRAINT ck_delivery_price_positive  CHECK (price_ht IS NULL OR price_ht >= 0),

    -- Une livraison facturée porte nécessairement un prix : l'incohérence
    -- « facturée sans montant » devient impossible.
    CONSTRAINT ck_delivery_billed_has_price
        CHECK (status <> 'BILLED' OR price_ht IS NOT NULL),
    CONSTRAINT ck_delivery_delivered_has_date
        CHECK (status <> 'DELIVERED' OR delivered_at IS NOT NULL)
);

-- Index dictés par les écrans réels, non par les clés étrangères.
-- Le client consulte SES livraisons, triées par date : index composite.
CREATE INDEX idx_delivery_customer_created ON delivery (customer_id, created_at DESC);
-- L'exploitation filtre par statut (« En attente » à traiter) : corrige D-04,
-- où le tri se faisait en mémoire Java faute d'index sur status.
CREATE INDEX idx_delivery_status_created   ON delivery (status, created_at DESC);
-- File de traitement : les livraisons en attente, les plus anciennes d'abord.
CREATE INDEX idx_delivery_pending          ON delivery (created_at)
    WHERE status = 'PENDING';

COMMENT ON TABLE  delivery IS 'Commande de livraison — cycle PENDING → ACCEPTED → IN_TRANSIT → DELIVERED → BILLED';
COMMENT ON COLUMN delivery.reference IS 'Référence métier lisible (LIV-2026-000123), communiquée au client';
COMMENT ON COLUMN delivery.volume_m3 IS 'Volume en m³ — NUMERIC et non INT : un colis peut mesurer 0,4 m³';

-- -----------------------------------------------------------------------------
-- Table : invoice
-- Exigée par la fiche (« gestion de la facturation »), absente de l'existant
-- où le prix était un simple champ sur la livraison.
-- Une facture peut regrouper plusieurs livraisons d'un même client sur une
-- période — c'est le mode de facturation B2B usuel.
-- -----------------------------------------------------------------------------

CREATE TABLE invoice (
    id             BIGINT         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reference      VARCHAR(20)    NOT NULL,
    customer_id    BIGINT         NOT NULL,
    status         invoice_status NOT NULL DEFAULT 'DRAFT',

    issued_at      TIMESTAMPTZ,
    due_at         TIMESTAMPTZ,
    paid_at        TIMESTAMPTZ,

    total_ht       NUMERIC(12,2)  NOT NULL DEFAULT 0,
    vat_rate       NUMERIC(5,2)   NOT NULL DEFAULT 20.00,
    total_ttc      NUMERIC(12,2)  NOT NULL DEFAULT 0,

    issued_by_user_id BIGINT,
    created_at     TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT uq_invoice_reference UNIQUE (reference),
    CONSTRAINT fk_invoice_customer
        FOREIGN KEY (customer_id) REFERENCES customer (id) ON DELETE RESTRICT,
    CONSTRAINT fk_invoice_issued_by
        FOREIGN KEY (issued_by_user_id) REFERENCES app_user (id) ON DELETE SET NULL,

    CONSTRAINT ck_invoice_totals_positive CHECK (total_ht >= 0 AND total_ttc >= 0),
    CONSTRAINT ck_invoice_vat_rate        CHECK (vat_rate >= 0 AND vat_rate <= 100),
    -- Une facture émise porte une date d'émission : la traçabilité comptable
    -- ne repose pas sur la bonne volonté du code applicatif.
    CONSTRAINT ck_invoice_issued_has_date
        CHECK (status = 'DRAFT' OR issued_at IS NOT NULL)
);

CREATE INDEX idx_invoice_customer_issued ON invoice (customer_id, issued_at DESC);
CREATE INDEX idx_invoice_status          ON invoice (status);

-- -----------------------------------------------------------------------------
-- Table : invoice_line
-- Une ligne de facture décrit une prestation facturée et son montant, au prix
-- retenu le jour de l'émission. Le montant est porté par la ligne elle-même :
-- une facture émise ne doit pas changer parce qu'un tarif a été corrigé après
-- coup. C'est une exigence comptable, pas une optimisation.
--
-- CHOIX DE CONCEPTION — pas de lien vers delivery
-- La ligne ne référence aucune livraison : elle est reliée à sa seule facture.
-- La livraison facturée est désignée en clair dans `label` (par exemple
-- « Livraison LIV-2026-000001 — Paris 11e → Paris 4e »).
--
-- Ce que ce choix simplifie : le schéma n'a plus de chemin circulaire
-- customer → delivery → invoice_line → invoice → customer, et la suppression
-- d'une livraison n'est plus retenue par une facture.
--
-- Ce que ce choix coûte, et qu'il faut assumer :
--   · aucune requête ne peut reconstituer les livraisons d'une facture, ni
--     savoir si une livraison donnée a déjà été facturée ;
--   · plus aucune contrainte n'empêche de facturer deux fois la même
--     livraison — le contrôle doit être porté par la couche service, donc par
--     la vigilance du code, ce que la base garantissait auparavant ;
--   · le rapprochement facture ↔ livraison repose sur du texte libre, non
--     vérifiable par le SGBD.
-- Rétablir la traçabilité supposerait de réintroduire une colonne
-- delivery_id et son unicité.
-- -----------------------------------------------------------------------------

CREATE TABLE invoice_line (
    id          BIGINT        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id  BIGINT        NOT NULL,
    label       VARCHAR(255)  NOT NULL,
    amount_ht   NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_invoice_line_invoice
        FOREIGN KEY (invoice_id) REFERENCES invoice (id) ON DELETE CASCADE,

    CONSTRAINT ck_invoice_line_amount CHECK (amount_ht >= 0)
);

CREATE INDEX idx_invoice_line_invoice ON invoice_line (invoice_id);

COMMENT ON COLUMN invoice_line.label IS
    'Désignation de la prestation facturée, référence de livraison comprise — texte libre, non contrôlé par le SGBD';

-- -----------------------------------------------------------------------------
-- Table : delivery_status_history
-- Corrige l'absence totale de traçabilité relevée par l'audit (« qui a facturé
-- quoi, et quand » — § Ce que le CRM ne fait pas).
-- Chaque changement de statut est journalisé : qui, quand, de quel état vers
-- quel état. C'est ce qui rend l'historique des livraisons exploitable et
-- l'action opposable.
-- -----------------------------------------------------------------------------

CREATE TABLE delivery_status_history (
    id             BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    delivery_id    BIGINT          NOT NULL,
    previous_status delivery_status,
    new_status     delivery_status NOT NULL,
    changed_by_user_id BIGINT,
    comment        VARCHAR(500),
    changed_at     TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT fk_dsh_delivery
        FOREIGN KEY (delivery_id) REFERENCES delivery (id) ON DELETE CASCADE,
    CONSTRAINT fk_dsh_user
        FOREIGN KEY (changed_by_user_id) REFERENCES app_user (id) ON DELETE SET NULL
);

CREATE INDEX idx_dsh_delivery_changed ON delivery_status_history (delivery_id, changed_at DESC);

COMMENT ON TABLE delivery_status_history IS 'Journal des transitions de statut — traçabilité absente de l''application existante';

-- -----------------------------------------------------------------------------
-- Déclencheur de mise à jour de updated_at
-- Évite de dépendre de la rigueur du code applicatif pour un champ technique.
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_app_user_updated_at BEFORE UPDATE ON app_user
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_customer_updated_at BEFORE UPDATE ON customer
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_delivery_updated_at BEFORE UPDATE ON delivery
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_invoice_updated_at BEFORE UPDATE ON invoice
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -----------------------------------------------------------------------------
-- Séquences de références métier
-- Une référence lisible par l'humain, distincte de la clé technique : le client
-- cite « LIV-2026-000042 » au téléphone, jamais l'identifiant de la ligne.
-- -----------------------------------------------------------------------------

CREATE SEQUENCE seq_delivery_reference START 1;
CREATE SEQUENCE seq_invoice_reference  START 1;
