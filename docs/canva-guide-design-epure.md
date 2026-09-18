# Guide de mise en forme Canva — design épuré

À utiliser avec `soutenance-texte-pour-canva.md`, qui contient le texte des 18 diapos.

---

## Le principe : une idée par diapo, beaucoup de blanc

Un design épuré ne se décrète pas avec un thème Canva — il se construit par
**soustraction**. Les quatre règles ci-dessous suffisent.

### 1. Deux couleurs, pas plus

| Usage | Hex | Où |
|---|---|---|
| Texte | `#1A1A1A` | Titres et corps |
| Accent | `#3D5A8A` | Chiffres clés, mots soulignés, filets |
| Fond | `#FFFFFF` | Partout |
| Gris clair | `#8A8680` | Mentions secondaires, numéros de diapo |

Le rouge **uniquement** sur les diapos 6, 7, 8 (les constats critiques) — et
seulement sur le chiffre, jamais sur une phrase entière. C'est ce contraste rare
qui lui donne sa force.

### 2. Deux tailles de texte par diapo

- **Titre** : 40 pt, gras
- **Corps** : 18 pt, normal
- **Chiffres clés** : 72 pt, gras

C'est tout. Pas de troisième niveau, pas d'italique décoratif.

### 3. Une seule police

**Inter** (ou *Helvetica*, ou *Poppins*) en Regular et Bold. Rien d'autre.
Une deuxième police ajoute du bruit sans ajouter de sens.

### 4. Des marges larges

Marge de **80 px minimum** sur les quatre côtés. Si le contenu ne rentre pas,
c'est qu'il y a trop de texte — coupe, ne réduis pas la marge.

---

## Les 4 gabarits à créer dans Canva

Crée ces 4 diapos une fois, puis duplique-les. Tu ne dessineras jamais rien deux fois.

### Gabarit A — Titre de section
*Diapos 1, 10*

```
┌────────────────────────────────────┐
│                                    │
│                                    │
│   Titre en 48 pt gras              │
│   ────────                         │  ← filet accent, 60 px de large
│                                    │
│   Sous-titre en 18 pt gris         │
│                                    │
│                                    │
└────────────────────────────────────┘
```

### Gabarit B — Trois chiffres
*Diapos 4, 6, 7, 16*

```
┌────────────────────────────────────┐
│  Titre 40 pt gras                  │
│  Sous-titre 16 pt gris             │
│                                    │
│    150         151         1       │  ← 72 pt gras
│    ─────       ─────       ─────   │
│    threads     connexions  marge   │  ← 14 pt gris majuscules
│    Tomcat      MySQL       !       │
│                                    │
└────────────────────────────────────┘
```

Le troisième chiffre en rouge `#A8342B` sur les diapos 6 et 7.

### Gabarit C — Liste
*Diapos 5, 9, 17*

```
┌────────────────────────────────────┐
│  Titre 40 pt gras                  │
│                                    │
│  D-02   Le service ne peut pas     │  ← code en accent, 14 pt mono
│         être répliqué              │  ← 18 pt, gras sur la 1re ligne
│                                    │
│  D-03   La saturation est à une    │
│         connexion près             │
│                                    │
└────────────────────────────────────┘
```

Espace vertical de **32 px** entre chaque entrée. C'est lui qui fait l'épuré.

### Gabarit D — Tableau
*Diapos 3, 8, 11, 15*

```
┌────────────────────────────────────┐
│  Titre 40 pt gras                  │
│                                    │
│  CONSTAT      →    OBJECTIF        │  ← en-tête 12 pt gris majuscules
│  ─────────────────────────────     │  ← 1 filet gris clair seulement
│  D-02 Session      Disponibilité   │
│  D-03 Connexions   Disponibilité   │
│  D-04 15,6 Mo      Performance     │
│                                    │
└────────────────────────────────────┘
```

**Pas de bordures de tableau.** Un seul filet sous l'en-tête. Canva met des
bordures partout par défaut : supprime-les.

---

## Ce qu'il faut supprimer des thèmes Canva

Les thèmes Canva ajoutent systématiquement des éléments qui cassent l'épuré :

- ❌ **Formes décoratives** en arrière-plan (cercles, vagues, dégradés)
- ❌ **Ombres portées** sur les blocs de texte
- ❌ **Icônes** à côté des titres
- ❌ **Bordures** de tableau
- ❌ **Couleurs de fond** sur les blocs

Pars d'une présentation **vierge** plutôt que d'un thème : tu passeras moins de
temps à enlever qu'à ajouter.

---

## Si tu veux aller plus vite

Dans Canva, tape `/` puis **« Ligne »** pour le filet d'accent, et utilise
**Position → Aligner** pour que tes blocs soient alignés au pixel. L'alignement
imparfait est ce qui distingue le plus un support amateur d'un support soigné.

Et active les **règles** (Fichier → Afficher les règles) pour tenir tes marges
de 80 px sur toutes les diapos.
