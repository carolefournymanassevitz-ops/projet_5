# Soutenance LiVrai — texte prêt à coller dans Canva

18 diapos · 18 min 10 s de contenu · créneau 15–20 min

**Comment t'en servir :** dans Canva, crée une présentation 16:9. Pour chaque diapo,
colle le titre, le sous-titre et le corps. Les **notes d'orateur** se collent dans le
panneau « Notes » sous chaque diapo (bouton *Notes* en bas de l'éditeur Canva).

**Palette suggérée** (à saisir dans Canva une fois, puis réutilisable) :

| Rôle | Hex |
|---|---|
| Encre / titres | `#16161A` |
| Texte courant | `#4A4740` |
| Accent (bleu ardoise) | `#3D5A8A` |
| Alerte / constats critiques | `#A8342B` |
| Résolu / points forts | `#1F6F4A` |
| Fond | `#FBFAF8` |

**Polices** : titres en *Fraunces* (ou *Playfair Display*), texte en *Inter*,
codes `D-xx` en *JetBrains Mono* (ou *Courier Prime*).

---

## Diapo 1 — Titre · 0:35

**Titre :** Du diagnostic à la refonte

**Sous-titre :** Audit du CRM de LiVrai, puis conception de l'architecture cible d'une application full-stack Java / Angular / PostgreSQL.

**Pied :** Carole Fourny-Manassevitz · Client LiVrai — Meilin, chef de projet · Septembre 2026

**NOTES :**
Bonjour, je suis Carole Fourny-Manassevitz. Je vous présente aujourd'hui un projet en deux temps pour la société LiVrai : d'abord l'audit de leur CRM existant, ensuite la conception de l'architecture cible de sa refonte.

Ces deux exercices sont liés par une règle que je vais suivre tout au long de cette présentation : chaque décision d'architecture que je propose devra descendre d'un constat mesuré dans l'audit.

⚠️ Respire. Cette diapo ne dure que 35 secondes — ne t'attarde pas, le jury veut du contenu.

---

## Diapo 2 — Le contexte · 0:50

**Titre :** Une entreprise qui grandit plus vite que son outil

**Sous-titre :** LiVrai, 150 employés, livraison de marchandises en grande quantité pour les professionnels. Le CRM interne soutient toute l'activité commerciale.

**3 blocs :**

| Signal 1 — CONSTATÉ | Signal 2 — CONSTATÉ | Signal 3 — ANTICIPÉ |
|---|---|---|
| **Lenteurs** | **Maintenance difficile** | **Disponibilité en pic** |
| Les équipes attendent devant les écrans de livraisons. | Chaque évolution coûte cher et fait peur. | Aucun incident encore survenu. À démontrer, pas à constater. |

**NOTES :**
LiVrai est une société de 150 employés qui livre des marchandises en grande quantité pour des professionnels. Leur CRM interne gère tout le cycle de vie d'une commande, de la prise de commande à la facturation.

Meilin, leur chef de projet, m'a transmis trois signaux. Et le premier travail d'un auditeur, c'est de comprendre qu'ils ne sont pas de même nature.

Les deux premiers — les lenteurs, la maintenance difficile — sont constatés : les équipes les vivent. Le troisième, la disponibilité en cas de pic, est anticipé : aucun incident n'a encore eu lieu.

⚠️ C'est ta transition vers la diapo suivante. Insiste sur « aucun incident n'a encore eu lieu » — c'est ce qui justifie ta méthode.

---

## Diapo 3 — Méthode d'audit · 0:45

**Titre :** Deux natures de signaux, deux méthodes

**Sous-titre :** Cette distinction gouverne tout le rapport : on ne démontre pas un fait observé comme on démontre un risque à venir.

**Tableau :**

| Nature | Méthode | Ce que ça donne sur LiVrai |
|---|---|---|
| Constaté | Je **remonte** du symptôme vers sa cause dans le code | « C'est lent » → connexions jamais fermées, requêtes non bornées, rechargement complet |
| Anticipé | Rien n'est observable : je **descends** de l'architecture vers un scénario | « Et en cas de pic ? » → scénario de rupture chiffré, seuil calculé |

**2 blocs bas :**
- **Ce que j'ai fait, et que beaucoup sautent** — J'ai déployé et parcouru l'application. MySQL 8 en conteneur, Tomcat 8.5, WAR déployé. Les deux profils, tous les parcours.
- **Ce que ça a changé** — Trois défauts supposés à la lecture sont devenus des preuves. Et plusieurs constats n'existaient que là.

**NOTES :**
Cette distinction gouverne toute ma méthode. Pour un problème constaté, je remonte du symptôme vers sa cause dans le code. Pour un risque anticipé, rien n'est observable : je pars de l'architecture et je construis un scénario de rupture.

Et puis il y a un point que beaucoup d'audits sautent, et qui a changé la moitié de mes constats : j'ai déployé l'application et je l'ai parcourue. MySQL en conteneur, Tomcat, le WAR déployé, et j'ai exercé les deux profils utilisateurs sur tous les parcours.

⚠️ À DIRE ABSOLUMENT : « Lire le code donne des hypothèses. L'exécuter donne des preuves. » — c'est la phrase qui te distingue.

---

## Diapo 4 — L'application existante · 1:00

**Titre :** Ce que j'ai trouvé sous le capot

**Sous-titre :** Application web Java monolithique : servlets, JSP, JDBC direct. Aucun framework. Déploiement en WAR sur un Tomcat unique.

**3 chiffres :**
- **13** classes Java — ~700 lignes. Intégralement analysable.
- **0** test automatisé — JUnit déclaré, jamais utilisé.
- **0** couche service — Le métier vit dans les servlets.

**Flux (5 étapes) :**
Navigateur (requête HTTP) → Filtre (auth + **1 requête SQL à chaque appel**) → Servlet (routage **et** logique métier) → DAO (`new UserDao()` à la main) → JSP (page HTML complète)

**NOTES :**
Techniquement : une application Java monolithique, servlets et JSP, accès JDBC direct. Aucun framework — ni Spring, ni Hibernate. Tout est écrit à la main.

Treize classes, sept cents lignes. C'est petit, et c'est en réalité un avantage : tout est analysable.

Mais regardez les deux autres chiffres : zéro test et zéro couche service. La logique métier vit dans les servlets.

Le schéma du bas suit une requête. Deux points à remarquer : le filtre d'authentification fait une requête SQL à chaque appel HTTP, même pour une image. Et le servlet instancie ses DAO à la main avec `new` — ce détail explique pourquoi ce code est intestable.

⚠️ Ne détaille pas les 5 étapes. Pointe le filtre, pointe le `new UserDao()`, et avance.

---

## Diapo 5 — Points forts · 0:50

**Titre :** D'abord, ce qui est sain

**Sous-titre :** Un audit qui ne voit que le négatif ne sert à personne. Ces acquis sont ce qu'on garde — et ils réduisent le risque de la refonte.

**Liste :**
- **F-02 — Aucune injection SQL possible.** Tous les accès passent par des `PreparedStatement` paramétrés. C'est la faille la plus répandue de cette génération d'applications — elle a été évitée.
- **F-03 — Un modèle de données propre.** Schéma normalisé, clé étrangère déclarée, `DECIMAL` pour les montants et non un flottant. Directement réutilisable.
- **F-04 — Aucune injection de script.** JSP sous `WEB-INF/`, échappement systématique par `<c:out>`.
- **F-01 — Un code intégralement lisible.** Pas de framework, donc pas de magie : on suit une requête de bout en bout. Une reprise complète tient en quelques jours.

**NOTES :**
Avant les problèmes, ce qui est sain. Un audit qui ne voit que le négatif, personne ne s'en sert — et surtout, ces acquis sont ce qu'on garde.

Toutes les requêtes sont paramétrées : aucune injection SQL possible. C'est la faille la plus répandue de cette génération d'applications, et elle a été évitée.

Le modèle de données est propre et normalisé : je le réutilise dans la cible. Et les vues échappent systématiquement le HTML : pas d'injection de script non plus.

Ces choix relèvent d'une vraie rigueur de la part de l'équipe qui a écrit ce code.

⚠️ TON : Ne méprise jamais l'existant. Une architecte qui arrive en disant « c'est nul » se trompe de métier. Ce code fonctionne et rend service depuis des années.

---

## Diapo 6 — La mesure clé · 1:05

**Titre :** La panne arrive avant la limite matérielle

**Sous-titre :** Le rapport entre deux valeurs de configuration transforme une inquiétude en risque calculable.

**3 chiffres :**
- **150** threads Tomcat max — Une connexion retenue par thread, jamais fermée.
- **151** connexions MySQL max — Plafond du serveur de base de données.
- **1** connexion de marge *(en rouge)* — Au-delà : refus de service total.

**2 blocs :**
- **Pourquoi c'est contre-intuitif** — La panne survient avant toute saturation processeur ou mémoire. Une supervision classique, qui surveille la machine, ne la voit pas venir.
- **Mesuré en fonctionnement** — 60 connexions ouvertes après une simple session de test, toutes à l'état `Sleep`. La plus ancienne depuis 897 secondes.

**NOTES :**
Voici la mesure qui porte tout mon rapport.

Tomcat est configuré à 150 threads maximum. MySQL accepte 151 connexions. Or chaque thread retient une connexion qu'il ne referme jamais — je l'ai vérifié : après une simple session de test, 60 connexions dormantes, la plus ancienne depuis près de 15 minutes.

Donc à pleine charge : 150 connexions ouvertes pour 151 autorisées. La marge est d'une seule connexion.

Et le point le plus important : cette panne survient avant toute saturation du processeur ou de la mémoire. Une supervision classique, qui surveille la machine, ne la voit pas venir.

⚠️ TEMPS FORT — c'est ton meilleur moment. Ralentis. Laisse un silence après « la marge est d'une seule connexion ».

---

## Diapo 7 — Volumétrie · 0:55

**Titre :** 15,6 Mo pour afficher un écran

**Sous-titre :** `getAllDeliveries()` charge toute la table, sans `LIMIT`, à chaque affichage.

**3 chiffres :**
- **3 Ko** avec 4 livraisons — L'application telle qu'elle a été conçue.
- **15,6 Mo** avec 20 004 livraisons *(en rouge)* — 20 006 lignes envoyées au navigateur.
- **242 Mo** mémoire, 10 requêtes *(en rouge)* — Sur un tas plafonné à 512 Mo.

**Bloc bas — Le point qui compte pour le métier :**
Cette dégradation est linéaire et sans palier, et elle est indépendante du nombre d'utilisateurs : elle empire avec le seul historique, que LiVrai accumule par construction. Chaque commande enregistrée alourdit définitivement l'écran principal.

**NOTES :**
Deuxième mesure. L'écran principal charge toute la table des livraisons, sans limite, à chaque affichage.

J'ai injecté 20 004 livraisons en base et j'ai appelé l'écran : 15,6 mégaoctets, plus de 20 000 lignes de tableau envoyées au navigateur. La même page avec 4 livraisons pèse 3 kilooctets.

Ce qu'il faut retenir, et c'est ce que je dirais au dirigeant : cette dégradation est linéaire, sans palier, et indépendante du nombre d'utilisateurs. Elle empire avec le seul historique — que LiVrai accumule par construction.

Autrement dit : plus l'entreprise réussit, plus l'application ralentit.

⚠️ La dernière phrase est ta formule-choc. « 15,6 Mo » ne parle pas à un décideur ; « plus vous réussissez, plus ça ralentit », si.

---

## Diapo 8 — Sécurité vérifiée · 1:10

**Titre :** Trois failles démontrées, pas supposées

**Sous-titre :** Chacune a été reproduite sur l'application en fonctionnement.

**Tableau :**

| Réf. | Ce que j'ai fait | Ce que j'ai obtenu |
|---|---|---|
| **D-09** | Appel de `/clients` depuis un compte **client** | **La liste complète des clients de LiVrai, avec leurs emails** — y compris des concurrents. Et création d'un utilisateur par `POST`. Fuite de données + élévation de privilège. |
| **D-05** | Création de deux comptes, puis lecture directe de la table `user` | **Les mots de passe y figurent en clair**, tels que saisis. Responsabilité RGPD engagée. |
| **D-10** | Commande avec volume `-99`, puis volume `abc` | **Le négatif est accepté, stocké, affiché et facturable.** Le texte produit un `HTTP 500` brut exposé à l'utilisateur. |
| **UX-06** | Clic sur « Refuser » une commande | `405 Method Not Allowed`, statut inchangé. **Refuser une commande était impossible en production.** |

**NOTES :**
Trois failles, et je souligne : toutes reproduites sur l'application en fonctionnement.

Avec un compte client ordinaire, j'ai appelé la page `/clients`. J'ai obtenu la liste complète des clients de LiVrai avec leurs adresses email — potentiellement des concurrents entre eux. Et j'ai pu créer un utilisateur. Fuite de données doublée d'une élévation de privilège.

J'ai créé deux comptes puis relu la table : les mots de passe sont en clair. Ça dépasse le technique — ça engage la responsabilité RGPD de LiVrai.

J'ai commandé une livraison de volume -99 : acceptée, stockée, affichée à l'administrateur, et facturable.

Et le bouton « Refuser » une commande : il ne fonctionne pas. 405, le statut ne change jamais.

⚠️ Précise que D-09 et UX-06 sont corrigeables tout de suite, sans attendre la refonte. Distinguer immédiat / structurel / obsolescence est une compétence d'architecte.

---

## Diapo 9 — Conclusion d'audit · 0:50

**Titre :** Trois risques déterminants

**Sous-titre :** Sur quatorze déficiences relevées, trois commandent la décision.

**Liste :**
- **D-02 — Le service ne peut pas être répliqué.** L'identité est en mémoire Tomcat. Ajouter un serveur déconnecte l'utilisateur en pleine saisie. Ni absorption de pic, ni suppression du point de défaillance unique.
- **D-03 — La saturation est à une connexion près.** 150 possibles pour 151 autorisées, et la panne précède toute limite matérielle.
- **D-04 — La dégradation par l'historique est sans palier.** Rien ne vient stabiliser la situation — au contraire, le succès commercial l'aggrave.

**Bloc bas — Facteur aggravant transverse :**
L'absence de tests et de couche service (D-01, D-07) ne crée aucune panne par elle-même — mais elle rend la correction de ces trois risques coûteuse et incertaine. C'est ce qui transforme un problème technique en **problème de trajectoire**.

**NOTES :**
J'ai relevé quatorze déficiences. Trois commandent la décision.

Premièrement : le service ne peut pas être répliqué. L'identité est stockée en mémoire du serveur. Ajouter un serveur derrière un répartiteur déconnecte l'utilisateur en pleine saisie. LiVrai ne peut donc ni absorber un pic, ni supprimer son point de défaillance unique.

Deuxièmement, la saturation à une connexion près. Troisièmement, la dégradation sans palier.

Et transversalement : l'absence de tests ne provoque aucune panne, mais elle rend la correction des trois autres coûteuse et risquée. C'est ce qui transforme un problème technique en problème de trajectoire.

⚠️ Le commanditaire doit retrouver ses mots dans ta conclusion : lenteurs → confirmé, maintenance → confirmé, disponibilité → risque avéré.

---

## Diapo 10 — Transition · 1:00

**Titre :** La règle que je me suis fixée

**Citation (grand, en italique) :**
« Qualifier les problèmes assez précisément pour que la solution devienne évidente — sans jamais l'écrire. »
*La frontière de l'audit : il établit l'existant, il ne choisit pas la cible.*

**2 blocs :**
- **Exercice 1 — l'audit** : Établit la *baseline*. Aucune techno recommandée, aucun « il faut ». Le commanditaire décide.
- **Exercice 2 — l'architecture** : La stack est **imposée** par le client. Mon travail n'est donc pas de la choisir, mais de **justifier qu'elle répond aux constats** — et de nommer ce qu'elle coûte.

**NOTES :**
Avant de passer à la cible, je veux nommer la frontière que je me suis imposée.

Un audit qualifie les problèmes assez précisément pour que la solution devienne évidente — sans jamais l'écrire. « Le service ne peut pas être répliqué » est un constat. « Il faut passer aux jetons JWT » est une décision qui ne m'appartenait pas à ce stade.

Dans le vocabulaire TOGAF, l'audit correspond à la phase B : il établit la baseline. La cible et l'analyse d'écart viennent après.

Et pour l'exercice 2, il y a un renversement qu'il faut expliciter : la stack m'est imposée par le client — Java, Angular, PostgreSQL, Docker. Mon travail n'est donc pas de la choisir, mais de justifier qu'elle répond aux constats, et de nommer ce qu'elle coûte.

❓ SI ON TE POUSSE SUR TOGAF : « Vous avez appliqué TOGAF ? » Non — et c'est délibéré. TOGAF pilote la transformation d'un SI entier avec une gouvernance. Le dérouler sur un CRM de treize classes serait une erreur de proportion. J'en emprunte le vocabulaire baseline / target, pas la méthode.

---

## Diapo 11 — Objectifs (DIAPO PIVOT) · 1:10

**Titre :** Chaque objectif descend d'un constat mesuré

**Sous-titre :** Pas de « moderniser l'appli ». Une cause, un objectif, une décision vérifiable.

**6 lignes « cause → objectif » :**

| Constat | → | Objectif |
|---|---|---|
| **D-02** Session en mémoire → réplication impossible | → | **Disponibilité** — back-end sans état, jeton JWT, N instances interchangeables |
| **D-03** 150 connexions pour 151, jamais fermées | → | **Disponibilité** — pool borné, transactions déclaratives |
| **D-04** 15,6 Mo par écran, sans palier | → | **Performance** — pagination imposée par le contrat d'API |
| **D-01 D-07** Métier dans les servlets, 0 test | → | **Maintenabilité** — couche service isolée et testable |
| **D-11** Java 1.6, Tomcat 8.5 en fin de vie | → | **Évolutivité** — socle supporté, API REST réutilisable |
| **D-05 D-06 D-09** Clair, secrets, fuite | → | **Sécurité** — BCrypt, secrets externalisés, refus par défaut |

**NOTES :**
Voici le cœur de mon document d'architecture : la traçabilité.

Chaque ligne se lit de gauche à droite — un constat mesuré, puis l'objectif qu'il impose. Jamais l'inverse, et jamais de « moderniser l'application » sans référence.

La session en mémoire impose un back-end sans état : c'est ce qui rend N instances interchangeables et lève le verrou de la disponibilité.

Les 150 connexions imposent un pool borné. Les 15,6 Mo imposent la pagination — et je l'ai mise dans le contrat d'API, pas en optimisation ultérieure. La logique dans les servlets impose une couche service. Le socle mort impose un socle supporté et une API réutilisable.

Les quatre objectifs demandés par Meilin — performance, disponibilité, maintenabilité, évolutivité — sont tous couverts, et chacun par un constat chiffré.

⚠️ C'est la diapo la plus importante des deux exercices. Prends ton temps. Si le jury ne retient qu'une chose, c'est celle-ci.

---

## Diapo 12 — Périmètre · 1:00

**Titre :** Le métier change, pas seulement la technique

**Sous-titre :** Aujourd'hui, le service commercial crée les comptes et commande pour le client. Il devient un goulot d'étranglement.

**3 blocs :**
- **Nouveau — autonomie** : Le client **crée son compte** et commande lui-même. Le commercial garde la main sur les comptes qu'il gère déjà : les deux voies coexistent.
- **Nouveau — exigé par la fiche** : **Gestion de la facturation** et **historique des livraisons**. Deux fonctions que l'audit listait comme absentes.
- **De 2 à 4 rôles** : Client · Commercial · Exploitation · Admin. Le booléen `admin` ne peut pas porter ça — c'est la cause de D-09.

**Bloc bas — Ce que j'ai explicitement écarté :**
Notifications, export comptable, réinitialisation autonome du mot de passe, suivi géolocalisé. **Aucun n'est dans la fiche.** C'est une refonte, pas un produit nouveau — et un périmètre qu'on ne borne pas est un projet qui dérape.

**NOTES :**
Le périmètre cible, maintenant. Et il y a un point que la fiche descriptive m'a appris, et que l'audit seul ne disait pas : ce n'est pas qu'une modernisation technique, c'est un changement de modèle opératoire.

Aujourd'hui, le service commercial crée chaque compte et réserve chaque livraison. Avec la croissance, il devient un goulot d'étranglement. La refonte rend les clients autonomes — tout en gardant la voie commerciale pour les clients qui la préfèrent. Les deux coexistent.

La fiche exige aussi deux fonctions que l'audit listait comme absentes : la facturation et l'historique.

Et on passe de deux à quatre rôles. Un simple booléen ne peut pas porter ça — c'est précisément la cause de la fuite de données que j'ai démontrée.

⚠️ Insiste sur ce que tu as écarté. Un candidat qui borne son périmètre rassure ; un candidat qui accepte tout inquiète.

---

## Diapo 13 — Architecture applicative · 1:10

**Titre :** Trois tiers, et une couche qui manquait

**Colonne gauche — les 4 couches (de haut en bas) :**
1. **Couche web — @RestController** : Routes REST, sérialisation, validation de format. **Aucune règle métier.**
2. **Couche service — @Service ← NOUVEAU** *(à mettre en vert)* : Règles métier, transitions de statut, visibilité par rôle, transactions. **Ne connaît ni HTTP ni JSON : testable sans serveur.**
3. **Repository — Spring Data JPA** : Interfaces, donc substituables en test. Requêtes paginées.
4. **PostgreSQL 18** : Contraintes d'intégrité — dernier rempart.

**Colonne droite — 3 blocs :**
- **Le choix d'architecture** : Monolithe modulaire, découpé par domaine métier et non par couche technique.
- **Microservices — écarté** : Six entités, une équipe réduite, aucune équipe plateforme. Le coût distribué dépasserait le bénéfice, et ne traiterait aucun des trois risques.
- **Ce que ça préserve** : Les frontières de domaine sont tracées. Si la facturation doit être extraite un jour, la découpe existe déjà.

**NOTES :**
L'architecture applicative. À gauche, les quatre couches — et la nouveauté, c'est celle du milieu.

La couche service porte les règles métier : les transitions de statut, la visibilité selon le rôle, les transactions. Et surtout, elle ne connaît ni HTTP ni JSON. C'est ça qui la rend testable sans démarrer un serveur — ce qui était strictement impossible dans l'existant.

À droite, mon choix de famille d'architecture : un monolithe modulaire, découpé par domaine métier et non par couche technique.

J'ai écarté les microservices, et je veux être explicite sur le raisonnement : le problème de LiVrai n'est pas la taille de son domaine — six entités — mais l'absence de séparation et l'état en mémoire. Découper en microservices ajouterait une complexité distribuée sans traiter aucun des trois risques. Et LiVrai n'a aucune équipe plateforme pour l'exploiter.

❓ QUESTION QUASI CERTAINE : « Pourquoi pas des microservices ? » → le raisonnement ci-dessus. Ajoute : le monolithe est modulaire, les frontières sont tracées. Si la facturation doit être extraite un jour, la découpe existe déjà. Un choix réversible vaut mieux qu'un choix ambitieux.

---

## Diapo 14 — Architecture opérationnelle · 1:10

**Titre :** Trois conteneurs, deux réseaux

**Sous-titre :** La fiche précise que **l'hébergeur n'est pas encore choisi**. C'est exactement ce à quoi Docker répond.

**3 blocs :**

| livrai-front | livrai-api ×N | livrai-db |
|---|---|---|
| **Nginx + Angular** | **Spring Boot** | **PostgreSQL 18** |
| Sert la SPA compilée, relaie `/api`. **Seul conteneur exposé.** | Sans état : **toute instance traite toute requête**. C'est elle qui absorbe les pics. | Réseau interne uniquement, **jamais joignable de l'extérieur**. Volume persistant. |

**2 blocs bas :**
- **Télémétrie — la leçon de D-03** : La panne arrivait avant toute limite matérielle. Surveiller la machine n'aurait rien vu. Premier indicateur : **taux d'occupation du pool de connexions**, alerte à 80 %.
- **Et aussi** : Journaux structurés JSON, sondes de santé, temps de réponse au 95ᵉ centile, taux de 5xx. L'existant n'avait **aucune journalisation**.

**NOTES :**
L'architecture opérationnelle. Trois conteneurs.

Le front, servi par Nginx — le seul exposé à l'extérieur. L'API Spring Boot, répliquée en N instances : c'est elle qui absorbe les pics, et elle ne le peut que parce qu'elle est sans état. Et la base, sur un réseau interne, jamais joignable de l'extérieur.

Un mot sur pourquoi Docker, au-delà du fait qu'il soit imposé : la fiche précise que l'hébergeur n'est pas encore choisi. La conteneurisation rend justement l'application indépendante de son hébergeur. Et elle corrige un défaut que j'avais relevé : aujourd'hui, changer d'environnement oblige à recompiler, parce que les identifiants de base sont codés en dur dans le source.

Pour la télémétrie, j'ai tiré une leçon directe de l'audit : puisque la panne arrive avant toute limite matérielle, surveiller la machine ne suffit pas. Mon premier indicateur est le taux d'occupation du pool de connexions.

⚠️ PIÈGE : Ne te contente pas de citer Docker. L'énoncé demande d'expliquer à quoi il sert dans ta proposition. L'argument « hébergeur non choisi » vient de la fiche — utilise-le.

---

## Diapo 15 — Modèle de données · 1:05

**Titre :** De 2 tables à 7 — et pourquoi chacune

**Tableau :**

| Existant | Cible | Le constat qui l'impose |
|---|---|---|
| `user.admin BOOLEAN` | `app_user.role` — énum 4 valeurs | **D-09** Un booléen ne porte pas quatre rôles |
| `user` = compte **et** client | `customer` + `customer_account` | Fiche : plusieurs personnes par entreprise cliente |
| `status VARCHAR(255)` en français | Type `delivery_status` | **D-14** Faute de frappe = état invalide silencieux |
| `volume INT` | `NUMERIC CHECK > 0` | **D-10** `-99` était accepté et facturable |
| `price` sur la livraison | `invoice` + `invoice_line` | Fiche : gestion de la facturation |
| Aucune trace des actions | `delivery_status_history` | Audit : « qui a facturé quoi, et quand » |

**NOTES :**
Le modèle de données. Deux tables deviennent sept, et chaque ligne de ce tableau porte sa justification.

Le booléen `admin` devient un type énuméré à quatre valeurs : c'est la correction structurelle de la fuite de données.

L'existant confondait le compte de connexion et l'entreprise cliente. Je les sépare, parce que la fiche prévoit que plusieurs personnes d'une même entreprise se connectent.

Le statut était un `VARCHAR` contenant du français accentué, comparé par égalité de chaînes jusque dans les pages JSP. Une faute de frappe créait un état invalide silencieux. Il devient un type énuméré.

Et j'ajoute une table d'historique des changements de statut : qui a accepté, refusé, facturé, et quand. L'audit avait relevé qu'aucune trace n'existait.

❓ SI ON TE REPROCHE DE T'ÉLOIGNER : « Vous n'avez pas gardé le modèle existant ? » Si — je le qualifie de sain et réutilisable dans l'audit (F-03). Les sept tables en sont l'évolution : je garde la normalisation, les clés étrangères, le DECIMAL. J'ajoute ce que le nouveau périmètre exige.

---

## Diapo 16 — Vérification · 1:00

**Titre :** Les scripts SQL ont réellement tourné

**Sous-titre :** Exécutés sur un vrai PostgreSQL 18 en conteneur, pas seulement écrits.

**2 blocs :**

**Le scénario D-10, rejoué en base**
```
INSERT volume -99, poids -50
→ ERROR: violates check constraint
  "ck_delivery_volume_positive"
```
La saisie que l'application acceptait, stockait et rendait facturable est désormais **impossible au niveau du stockage** — et pas seulement corrigée dans le code.

**Ce que la base garantit désormais**
Volume et poids strictement positifs · une livraison facturée porte obligatoirement un prix · une livraison livrée porte une date · statuts et rôles contraints par des types énumérés · unicité des références métier.

*Chaque état invalide devient irreprésentable, quel que soit le chemin d'écriture.*

**3 chiffres (en vert) :**
- **7** tables créées — Types énumérés, contraintes, 9 index, déclencheurs.
- **4** rôles seedés — 8 comptes, 3 entreprises, 6 livraisons.
- **6** statuts couverts — Tout le cycle de vie, journal compris.

**NOTES :**
Un point sur lequel je veux être précise : je n'ai pas seulement écrit ces scripts, je les ai exécutés sur un vrai PostgreSQL 18 en conteneur.

Et j'ai testé que les contraintes font ce qu'elles promettent. J'ai rejoué le scénario exact que j'avais démontré dans l'audit — insérer un volume de -99. La base le refuse.

C'est le point que je trouve le plus satisfaisant du projet : le défaut que j'ai constaté en exerçant l'application est maintenant structurellement impossible, et pas seulement corrigé dans le code. Même un script de reprise ou une correction manuelle ne pourrait pas créer cet état.

Idem pour la double facturation d'une même livraison : rejetée par une contrainte d'unicité.

⚠️ Peu de candidats exécutent leurs scripts. C'est un différenciateur — dis-le simplement, sans en faire trop.

---

## Diapo 17 — Arbitrages · 1:20

**Titre :** Trois décisions que j'assume, et leur prix

**Sous-titre :** Une architecture n'est jamais « bonne » dans l'absolu : elle arbitre entre des qualités qui s'opposent.

**Liste :**
- **ADR-03 — JWT plutôt que session partagée.** Le coût : un jeton ne se révoque pas avant expiration — désactiver un compte n'est pas immédiat. Je le borne à 15 minutes avec un jeton de rafraîchissement. L'alternative Redis supprimerait ce défaut mais réintroduirait un composant à état à exploiter.
- **ADR-09 — Signaux Angular plutôt que NgRx.** L'énoncé l'encourage ; je l'écarte. Redux impose actions, réducteurs et effets pour chaque interaction — sur un état de cette taille, la cérémonie dépasse le bénéfice. L'état étant isolé par domaine, la décision reste réversible.
- **« Gérer certains clients » : tout commercial voit tout.** La fiche suggère une affectation nominative. À 150 employés et quelques commerciaux qui travaillent en commun, ce serait une cloison interne coûteuse pour un problème qui n'existe pas. Je le note en hors périmètre, et la règle vivant dans la couche service, l'ajouter plus tard resterait localisé.

**NOTES :**
Trois arbitrages, parce qu'une architecture n'est jamais bonne dans l'absolu : elle arbitre entre des qualités qui s'opposent. Et une architecte qui ne nomme pas le prix de ce qu'elle préconise vend du rêve.

Le JWT me donne l'absence d'état, donc la réplication. Mais un jeton ne se révoque pas avant son expiration : désactiver un compte n'est pas immédiat. Je le borne à quinze minutes.

NgRx est encouragé par l'énoncé, et je l'écarte. Le patron Redux impose actions, réducteurs et effets pour chaque interaction. Sur un état de cette taille, la cérémonie dépasse le bénéfice. Et comme l'état est isolé par domaine, la décision reste réversible.

Enfin, la fiche dit que le commercial gère « certains clients ». J'ai tranché : tout commercial voit tout le portefeuille. À 150 employés, cloisonner une équipe qui travaille en commun coûterait une complexité permanente pour un problème qui n'existe pas. Je le note en hors périmètre plutôt que de l'ignorer.

❓ QUESTION PROBABLE : « Pourquoi pas NgRx, c'était recommandé ? » Parce que recommandé n'est pas imposé, et qu'un pattern excellent à grande échelle est de la sur-ingénierie à petite échelle. J'ai nommé la condition qui me ferait changer d'avis.

---

## Diapo 18 — Conclusion · 1:15

**Titre :** Ce que je livre, et ce qui reste ouvert

**2 blocs :**

**Livré** *(en vert)*
- **Rapport d'audit** — 14 déficiences, 6 points forts, mesures en fonctionnement.
- **Document d'architecture** — contexte, fonctionnel, technique, modèle de données, 10 ADR.
- **Scripts PostgreSQL** — schéma, seed, exécutés et vérifiés.

**Volontairement non tranché** *(en orange)*
- **Haute disponibilité de la base** — dépend de l'hébergeur, non choisi.
- **Reprise des données** — les mots de passe en clair ne sont pas migrables : tous les utilisateurs devront en redéfinir un.
- **Test de charge** — à mener avant mise en service.

**Citation finale (grand, italique) :**
« Les difficultés de LiVrai ne traduisent pas un défaut de réalisation, mais l'écart entre l'échelle pour laquelle l'application a été conçue et celle que l'entreprise atteint aujourd'hui. »

**NOTES :**
Pour conclure. Je livre trois documents : le rapport d'audit, le document d'architecture avec ses dix décisions tracées, et les scripts PostgreSQL vérifiés.

Et je tiens à nommer ce que je n'ai pas tranché, parce que les taire serait une faute : la haute disponibilité de la base dépend de l'hébergeur, qui n'est pas choisi. La reprise des données est un chantier distinct — et j'attire l'attention sur un point sensible : les mots de passe étant stockés en clair, ils ne sont pas migrables. Tous les utilisateurs devront en redéfinir un le jour de la bascule. Enfin, le test de charge reste à mener.

Un dernier mot sur l'état d'esprit. Les difficultés de LiVrai ne traduisent pas un défaut de réalisation. Elles traduisent l'écart entre l'échelle pour laquelle l'application a été conçue, et celle que l'entreprise atteint aujourd'hui.

Je vous remercie, et je suis à votre disposition pour vos questions.

⚠️ Termine sur la phrase de l'écart — elle montre que tu respectes le travail existant. Puis tais-toi et souris. Ne meuble pas.
