# Prompt Canva — soutenance LiVrai

Ce fichier contient **un seul texte à coller** dans l'assistant IA de Canva
(« Magic Design » / « Créer avec l'IA » → *Présentation*).

## Mode d'emploi

1. Dans Canva, crée une **Présentation (16:9)**
2. Ouvre l'assistant IA et colle **tout le bloc « PROMPT » ci-dessous**
3. Canva génère les 18 diapos ; tu ajustes ensuite
4. Insère les 4 schémas depuis `docs/schemas/` (voir la table en fin de fichier)
5. Colle les notes d'orateur depuis `soutenance-texte-pour-canva.md`

> **À savoir :** l'IA de Canva ne reprend pas toujours un texte long au mot près.
> Elle est bonne pour la **mise en page** ; vérifie que les chiffres n'ont pas été
> arrondis ou reformulés. Les chiffres de cette soutenance sont des mesures
> d'audit : `150`, `151`, `15,6 Mo`, `20 004`, `242 Mo`, `60`, `897 s`.
> S'ils changent, corrige-les à la main.

---

# PROMPT — à copier intégralement

Crée une présentation professionnelle de 18 diapositives au format 16:9 pour une
soutenance technique d'architecture logicielle.

**Sujet :** audit d'une application de gestion de livraisons vieillissante, puis
conception de son architecture de remplacement.

**Style visuel — sobre et épuré, style document d'ingénierie :**
- Fond blanc uni, aucune forme décorative, aucun dégradé, aucune ombre portée
- Deux couleurs seulement : texte presque noir (#1A1A1A) et un bleu ardoise (#3D5A8A) pour les accents
- Un rouge brique (#A8342B) réservé aux trois chiffres d'alerte, rien d'autre
- Un vert sobre (#1F6F4A) pour les éléments résolus
- Une seule police sans-serif, en deux graisses (normal et gras)
- Marges larges, beaucoup d'espace blanc, alignement à gauche
- Pas d'icônes, pas de pictogrammes, pas d'emoji
- Les grands chiffres sont l'élément visuel principal : très grande taille, gras

**Contenu des 18 diapositives :**

1. Titre : « Du diagnostic à la refonte ». Sous-titre : « Audit du CRM de LiVrai, puis conception de l'architecture cible d'une application full-stack Java / Angular / PostgreSQL ». Pied de page : « Carole Fourny-Manassevitz — Septembre 2026 ».

2. Titre : « Une entreprise qui grandit plus vite que son outil ». Trois blocs côte à côte : « Lenteurs — constaté », « Maintenance difficile — constaté », « Disponibilité en pic — anticipé, aucun incident encore survenu ».

3. Titre : « Deux natures de signaux, deux méthodes ». Tableau à deux lignes : « Constaté → je remonte du symptôme vers sa cause dans le code » et « Anticipé → rien n'est observable, je descends de l'architecture vers un scénario ». Encadré : « J'ai déployé et parcouru l'application — trois défauts supposés sont devenus des preuves ».

4. Titre : « Ce que j'ai trouvé sous le capot ». Trois grands chiffres : « 13 classes Java », « 0 test automatisé », « 0 couche service ». Sous-titre : « Application Java monolithique, servlets et JSP, aucun framework ».

5. Titre : « D'abord, ce qui est sain ». Liste de quatre points : « Aucune injection SQL possible — requêtes paramétrées », « Un modèle de données propre et normalisé », « Aucune injection de script — échappement systématique », « Un code intégralement lisible — 700 lignes ».

6. Titre : « La panne arrive avant la limite matérielle ». Trois très grands chiffres : « 150 threads Tomcat maximum », « 151 connexions MySQL maximum », « 1 seule connexion de marge » — ce dernier en rouge. Note : « 60 connexions dormantes mesurées après une session de test ».

7. Titre : « 15,6 Mo pour afficher un écran ». Trois grands chiffres : « 3 Ko avec 4 livraisons », « 15,6 Mo avec 20 004 livraisons » en rouge, « 242 Mo de mémoire pour 10 requêtes » en rouge. Phrase de conclusion en gras : « Plus l'entreprise réussit, plus l'application ralentit ».

8. Titre : « Trois failles démontrées, pas supposées ». Tableau de quatre lignes : un compte client a listé tous les clients avec leurs emails ; les mots de passe sont stockés en clair ; un volume de -99 est accepté et facturable ; le bouton Refuser renvoie une erreur 405 et ne fonctionne pas.

9. Titre : « Trois risques déterminants ». Liste : « Le service ne peut pas être répliqué », « La saturation est à une connexion près », « La dégradation par l'historique est sans palier ».

10. Titre : « La règle que je me suis fixée ». Grande citation centrée : « Qualifier les problèmes assez précisément pour que la solution devienne évidente — sans jamais l'écrire ». Deux blocs : « L'audit établit l'existant » et « L'architecture répond aux constats — la stack est imposée par le client ».

11. Titre : « Chaque objectif descend d'un constat mesuré ». Tableau de six lignes reliant une cause à un objectif : session en mémoire → disponibilité ; 150 connexions pour 151 → disponibilité ; 15,6 Mo par écran → performance ; aucun test → maintenabilité ; socle en fin de vie → évolutivité ; mots de passe en clair → sécurité.

12. Titre : « Le métier change, pas seulement la technique ». Trois blocs : « Le client crée son compte et commande lui-même », « Facturation et historique — exigés par le client », « De 2 à 4 rôles : client, commercial, exploitation, admin ». Encadré : « Explicitement écarté : notifications, export comptable, suivi géolocalisé ».

13. Titre : « Trois tiers, et une couche qui manquait ». Prévoir une grande zone d'image à gauche pour un schéma d'architecture. À droite, trois blocs : « Monolithe modulaire », « Microservices écartés — six entités, aucune équipe plateforme », « Les frontières de domaine sont tracées ».

14. Titre : « Trois conteneurs, deux réseaux ». Prévoir une grande zone d'image pour un schéma de déploiement. Ajouter un encadré : « Premier indicateur à surveiller : le taux d'occupation du pool de connexions ».

15. Titre : « De 2 tables à 7 ». Prévoir une grande zone d'image pour un schéma de base de données. Ajouter une note : « Chaque table nouvelle corrige un constat d'audit ».

16. Titre : « Les scripts SQL ont réellement tourné ». Bloc de code : « INSERT volume -99 → ERROR: violates check constraint ck_delivery_volume_positive ». Trois chiffres en vert : « 7 tables créées », « 4 rôles », « 6 statuts couverts ».

17. Titre : « Trois décisions que j'assume, et leur prix ». Liste de trois points longs : le jeton JWT et son coût — un jeton ne se révoque pas avant expiration ; les signaux Angular plutôt que NgRx — la cérémonie dépasse le bénéfice ; tout commercial voit tout le portefeuille — cloisonner coûterait plus que ça ne rapporte.

18. Titre : « Ce que je livre, et ce qui reste ouvert ». Deux colonnes : à gauche en vert « Rapport d'audit, document d'architecture, scripts PostgreSQL vérifiés » ; à droite en orange « Haute disponibilité de la base, reprise des données, test de charge ». Citation finale : « Les difficultés de LiVrai ne traduisent pas un défaut de réalisation, mais l'écart entre l'échelle pour laquelle l'application a été conçue et celle que l'entreprise atteint aujourd'hui ».

Réserve de l'espace pour des notes d'orateur sous chaque diapositive.

# FIN DU PROMPT

---

## Les schémas à insérer

Je les ai exportés en PNG haute résolution dans **`docs/schemas/`**. Dans Canva :
*Téléverser* → glisser l'image dans la zone réservée.

| Diapo | Image | Ce qu'elle montre |
|---|---|---|
| **13** | `vue-ensemble.png` ou `couches-backend.png` | Les trois tiers, ou les 4 couches du back-end |
| **14** | `docker.png` | Les 3 conteneurs, 2 réseaux, parcours numéroté |
| **15** | `modele-donnees.png` | Les 7 tables et leurs relations |
| *(option)* | `cas-utilisation.png` | Les 4 acteurs et leurs cas d'usage — à glisser en diapo 12 |
| *(option)* | `cycle-livraison.png` | Le cycle de vie d'une livraison — à glisser en diapo 12 ou 15 |

**Conseil de mise en page :** sur les diapos 13, 14 et 15, donne au schéma
**au moins la moitié de la surface**. Un schéma d'architecture illisible ne
sert à rien — mieux vaut moins de texte autour.

---

## Après génération : la liste de contrôle

- [ ] Les chiffres sont exacts : `150`, `151`, `15,6 Mo`, `20 004`, `242 Mo`, `60`, `897 s`
- [ ] Les références d'audit sont présentes : `D-01` à `D-14`, `F-01` à `F-06`, `UX-01` à `UX-07`
- [ ] Le rouge n'apparaît que sur les diapos 6, 7 et 8
- [ ] Aucune icône ni emoji n'a été ajouté par Canva
- [ ] Les trois schémas sont lisibles en plein écran
- [ ] Les notes d'orateur sont collées sous chaque diapo
- [ ] Le total tient en 18 minutes — répète avec un chrono

Si Canva ajoute des formes décoratives ou des dégradés, sélectionne-les et
supprime-les : c'est le principal écart entre le rendu généré et le style épuré
que tu veux.
