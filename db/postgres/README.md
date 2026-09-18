# Scripts PostgreSQL — CRM LiVrai (cible)

Scripts de création de la nouvelle structure de données, référencés par le
document d'architecture (`docs/architecture-livrai.html`, § 4).

| Fichier | Rôle | Production |
|---|---|---|
| `01-schema.sql` | Types, tables, contraintes, index, déclencheurs | Oui |
| `02-seed.sql` | Jeu de données de démonstration | **Non** — développement et recette uniquement |

## Exécution

```bash
# Via Docker Compose (les scripts sont montés dans docker-entrypoint-initdb.d)
docker compose up -d db

# Ou directement sur une base existante
psql -U livrai -d livrai -f 01-schema.sql
psql -U livrai -d livrai -f 02-seed.sql   # développement seulement
```

## Points d'attention

- **`02-seed.sql` ne va jamais en production.** Les mots de passe des comptes de
  démonstration sont publics (`Livrai2026!`). En production, le compte
  d'administration initial est créé par le script de démarrage applicatif, avec
  un secret injecté par l'environnement.
- **Les empreintes BCrypt du seed sont toutes identiques** parce que le mot de
  passe l'est aussi. C'est acceptable pour un jeu de démonstration ; en usage
  réel, chaque hachage est unique grâce au sel généré par BCrypt.
- **Migrations.** Ces scripts posent l'état initial. En développement continu,
  l'évolution du schéma est prise en charge par Flyway (`src/main/resources/db/migration`)
  afin que chaque changement soit versionné et rejouable — voir § 4.5 du document
  d'architecture.

## Correspondance avec les constats d'audit

| Constat | Traitement dans le schéma |
|---|---|
| D-05 mots de passe en clair | `password_hash`, empreinte BCrypt |
| D-09 autorisation par booléen `admin` | Type `user_role` à quatre valeurs |
| D-10 volume `-99` accepté | `CHECK (volume_m3 > 0)`, `CHECK (weight_kg > 0)` |
| D-14 statuts en texte libre français | Types `delivery_status` / `invoice_status` |
| D-04 aucun index sur `status` | `idx_delivery_status_created`, index partiel `idx_delivery_pending` |
| Absence de traçabilité des statuts | Table `delivery_status_history` |

## Choix de conception assumé — facture et livraison non reliées

`invoice_line` ne porte **pas** de clé étrangère vers `delivery`. La livraison
facturée est désignée en clair dans `invoice_line.label`.

Ce choix supprime le chemin circulaire
`customer → delivery → invoice_line → invoice → customer` et allège le schéma.

Il a un coût, à connaître et à pouvoir défendre :

- aucune requête ne reconstitue les livraisons d'une facture ;
- **rien n'empêche plus de facturer deux fois la même livraison** — ce contrôle,
  auparavant garanti par une contrainte `UNIQUE`, doit être implémenté dans la
  couche service ;
- le rapprochement facture ↔ livraison repose sur du texte non vérifiable.

Si la traçabilité comptable devenait nécessaire, il faudrait réintroduire
`invoice_line.delivery_id` avec sa contrainte d'unicité.
