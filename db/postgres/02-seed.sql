-- =============================================================================
-- LiVrai CRM — Jeu de données initial (environnement de développement)
--
-- ATTENTION : ce script est destiné au développement et à la recette.
-- Il ne doit PAS être exécuté en production : les mots de passe des comptes de
-- démonstration sont connus. En production, seul le compte d'administration
-- initial est créé, avec un secret fourni par l'environnement.
--
-- Les empreintes ci-dessous sont des hachages BCrypt (coût 10) — l'application
-- ne stocke jamais de mot de passe en clair (corrige D-05 de l'audit).
-- Mot de passe des comptes de démonstration : « Livrai2026! »
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Comptes internes
-- -----------------------------------------------------------------------------

INSERT INTO app_user (email, password_hash, first_name, last_name, role) VALUES
    ('admin@livrai.fr',      '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin',  'LiVrai',   'ADMIN'),
    ('meilin@livrai.fr',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Meilin', 'Zhao',     'COMMERCIAL'),
    ('commercial@livrai.fr', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Paul',   'Mercier',  'COMMERCIAL'),
    ('exploit@livrai.fr',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Sarah',  'Bouvier',  'EXPLOITATION');

-- -----------------------------------------------------------------------------
-- Entreprises clientes
-- -----------------------------------------------------------------------------

INSERT INTO customer (company_name, siret, contact_email, contact_phone,
                      billing_street, billing_post_code, billing_city) VALUES
    ('Boulangerie Durand',  '12345678901234', 'contact@durand.fr',  '0140000001', '12 rue du Pain',       '75011', 'Paris'),
    ('Ateliers Moreau',     '23456789012345', 'logistique@moreau.fr','0140000002', '8 avenue des Forges',  '69003', 'Lyon'),
    ('Pharmacie Centrale',  NULL,             'gerant@pharma-c.fr', '0140000003', '3 place de la Mairie', '33000', 'Bordeaux');

-- -----------------------------------------------------------------------------
-- Comptes clients, rattachés à leur entreprise
-- Le premier client a deux comptes : le gérant et l'assistante logistique.
-- C'est précisément ce que l'ancien modèle (un compte = un client) interdisait.
-- -----------------------------------------------------------------------------

INSERT INTO app_user (email, password_hash, first_name, last_name, role) VALUES
    ('gerant@durand.fr',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Claire', 'Durand',  'CLIENT'),
    ('logistique@durand.fr', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Yanis',  'Berger',  'CLIENT'),
    ('contact@moreau.fr',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Hélène', 'Moreau',  'CLIENT'),
    ('gerant@pharma-c.fr',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Marc',   'Lefèvre', 'CLIENT');

INSERT INTO customer_account (customer_id, user_id)
SELECT c.id, u.id FROM customer c, app_user u
WHERE (c.company_name = 'Boulangerie Durand' AND u.email IN ('gerant@durand.fr', 'logistique@durand.fr'))
   OR (c.company_name = 'Ateliers Moreau'    AND u.email = 'contact@moreau.fr')
   OR (c.company_name = 'Pharmacie Centrale' AND u.email = 'gerant@pharma-c.fr');

-- -----------------------------------------------------------------------------
-- Livraisons couvrant l'ensemble du cycle de vie
-- -----------------------------------------------------------------------------

INSERT INTO delivery (reference, customer_id, created_by_user_id, status,
                      volume_m3, weight_kg,
                      pickup_street, pickup_post_code, pickup_city,
                      delivery_street, delivery_post_code, delivery_city,
                      requested_pickup_at, delivered_at, price_ht)
SELECT
    v.reference, c.id, u.id, v.status::delivery_status,
    v.volume, v.weight,
    v.p_street, v.p_cp, v.p_city,
    v.d_street, v.d_cp, v.d_city,
    v.pickup_at, v.delivered_at, v.price
FROM (VALUES
    ('LIV-2026-000001', 'Boulangerie Durand', 'gerant@durand.fr',     'BILLED',
     2.500,  120.000, '12 rue du Pain', '75011', 'Paris',
     '45 rue de Rivoli', '75004', 'Paris',
     now() - interval '20 days', now() - interval '18 days', 180.00),

    ('LIV-2026-000002', 'Boulangerie Durand', 'logistique@durand.fr', 'DELIVERED',
     1.200,   60.000, '12 rue du Pain', '75011', 'Paris',
     '9 boulevard Voltaire', '75011', 'Paris',
     now() - interval '6 days', now() - interval '4 days', 95.00),

    ('LIV-2026-000003', 'Ateliers Moreau',    'contact@moreau.fr',    'IN_TRANSIT',
     8.000, 1450.000, '8 avenue des Forges', '69003', 'Lyon',
     '120 route de Vienne', '69007', 'Lyon',
     now() - interval '1 day', NULL, 420.00),

    ('LIV-2026-000004', 'Ateliers Moreau',    'contact@moreau.fr',    'ACCEPTED',
     3.750,  300.000, '8 avenue des Forges', '69003', 'Lyon',
     '5 quai Perrache', '69002', 'Lyon',
     now() + interval '2 days', NULL, NULL),

    ('LIV-2026-000005', 'Pharmacie Centrale', 'gerant@pharma-c.fr',   'PENDING',
     0.400,   18.500, '3 place de la Mairie', '33000', 'Bordeaux',
     '27 cours de l''Intendance', '33000', 'Bordeaux',
     now() + interval '3 days', NULL, NULL),

    ('LIV-2026-000006', 'Pharmacie Centrale', 'gerant@pharma-c.fr',   'REJECTED',
     15.000, 3200.000, '3 place de la Mairie', '33000', 'Bordeaux',
     '1 rue Sainte-Catherine', '33000', 'Bordeaux',
     now() - interval '2 days', NULL, NULL)
) AS v(reference, company, creator_email, status, volume, weight,
       p_street, p_cp, p_city, d_street, d_cp, d_city,
       pickup_at, delivered_at, price)
JOIN customer c ON c.company_name = v.company
JOIN app_user u ON u.email        = v.creator_email;

-- -----------------------------------------------------------------------------
-- Journal des statuts
-- Reconstitue la trajectoire de la livraison facturée : c'est ce que
-- l'application existante ne conservait nulle part.
-- -----------------------------------------------------------------------------

INSERT INTO delivery_status_history (delivery_id, previous_status, new_status,
                                     changed_by_user_id, comment, changed_at)
SELECT d.id, h.prev::delivery_status, h.next::delivery_status, u.id, h.comment, h.at
FROM (VALUES
    ('LIV-2026-000001', NULL,        'PENDING',    'gerant@durand.fr',  'Commande créée par le client',      now() - interval '22 days'),
    ('LIV-2026-000001', 'PENDING',   'ACCEPTED',   'exploit@livrai.fr', 'Créneau confirmé',                  now() - interval '21 days'),
    ('LIV-2026-000001', 'ACCEPTED',  'IN_TRANSIT', 'exploit@livrai.fr', 'Enlèvement effectué',               now() - interval '20 days'),
    ('LIV-2026-000001', 'IN_TRANSIT','DELIVERED',  'exploit@livrai.fr', 'Remise au destinataire',            now() - interval '18 days'),
    ('LIV-2026-000001', 'DELIVERED', 'BILLED',     'meilin@livrai.fr',  'Facture FAC-2026-000001 émise',     now() - interval '15 days'),
    ('LIV-2026-000006', NULL,        'PENDING',    'gerant@pharma-c.fr','Commande créée par le client',      now() - interval '3 days'),
    ('LIV-2026-000006', 'PENDING',   'REJECTED',   'exploit@livrai.fr', 'Poids au-delà de la capacité',      now() - interval '2 days')
) AS h(reference, prev, next, actor_email, comment, at)
JOIN delivery d ON d.reference = h.reference
JOIN app_user u ON u.email     = h.actor_email;

-- -----------------------------------------------------------------------------
-- Facture d'exemple
-- -----------------------------------------------------------------------------

INSERT INTO invoice (reference, customer_id, status, issued_at, due_at,
                     total_ht, vat_rate, total_ttc, issued_by_user_id)
SELECT 'FAC-2026-000001', c.id, 'ISSUED',
       now() - interval '15 days', now() + interval '15 days',
       180.00, 20.00, 216.00, u.id
FROM customer c, app_user u
WHERE c.company_name = 'Boulangerie Durand' AND u.email = 'meilin@livrai.fr';

INSERT INTO invoice_line (invoice_id, delivery_id, label, amount_ht)
SELECT i.id, d.id, 'Livraison LIV-2026-000001 — Paris 11e → Paris 4e', 180.00
FROM invoice i, delivery d
WHERE i.reference = 'FAC-2026-000001' AND d.reference = 'LIV-2026-000001';

-- Aligne les séquences sur les références déjà insérées.
SELECT setval('seq_delivery_reference', 6);
SELECT setval('seq_invoice_reference',  1);
