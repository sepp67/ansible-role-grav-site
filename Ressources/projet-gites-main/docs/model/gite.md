# Modèle de contenu — Gîte

Document de référence sur le modèle de contenu d'un gîte, construit progressivement :

- **TASK-002-01-01** — identification des champs nécessaires (section ci-dessous) ;
- **TASK-002-01-02** — définition du schéma YAML formel (section ci-dessous) ;
- **TASK-002-01-03** — documentation finale de la structure (section ci-dessous).

Conforme à DR-011 (Modèle de contenu des hébergements) : chaque gîte est représenté par une page Grav structurée, selon un modèle simple et extensible.

## Champs identifiés (TASK-002-01-01)

| Champ | Justification | Porté par |
|---|---|---|
| Nom du gîte | Titre de la fiche | Champ natif Grav (`title` de la page) |
| Description | Explicitement listée comme composant de la fiche (`project-context.md`) | Corps Markdown de la page |
| Caractéristiques / équipements | « caractéristiques » (FEAT-002-01) et « équipements » (`project-context.md`) | Métadonnées YAML |
| Informations pratiques | Explicitement listée comme composant de la fiche (`project-context.md`) | Métadonnées YAML |
| Coordonnées de localisation (latitude/longitude, adresse) | « coordonnées » (FEAT-002-01) ; nécessaires à la carte de localisation (EPIC-007) | Métadonnées YAML |
| Propriétaire (référence) | « propriétaire » (FEAT-002-01) ; nécessaire aux permissions d'accès (EPIC-005) et à la détermination du destinataire du formulaire de contact (TASK-004-02-03) | Métadonnées YAML |
| Galerie photographique | Explicitement listée comme composant de la fiche (`project-context.md`) | Fichiers média natifs du dossier de page **et** métadonnées YAML (`galerie.photos`, cf. section « Galerie photographique — modèle de métadonnées » ci-dessous, évolution actée pour la nouvelle présentation photographique) |

## Structure YAML (TASK-002-01-02)

Schéma des métadonnées de la page d'un gîte, conforme à `docs/conventions/yaml.md` (clés Grav natives en anglais, champs métier en français `snake_case` sans accent) :

```yaml
---
title: Nom du gîte              # champ natif Grav

proprietaire: slug-du-compte    # référence stable au compte du plugin Login (pas d'e-mail en clair)

equipements:
  - Wifi
  - Cheminée
  - Jardin

capacite_max: 6
nombre_chambres: 3

informations_pratiques:
  arrivee: "à partir de 16h"
  depart: "avant 10h"
  animaux_acceptes: false

coordonnees:
  adresse: "12 rue Example, 68000 Colmar"
  latitude: 48.0779
  longitude: 7.3567
---
```

### Décisions actant les observations de TASK-002-01-01

- **Équipements** : liste de texte libre (pas de vocabulaire contrôlé), conforme à DR-020 (simplicité) ; un vocabulaire contrôlé reste une évolution possible non nécessaire pour 2 gîtes.
- **Coordonnées** : `latitude`/`longitude` en degrés décimaux + `adresse` texte — format directement exploitable par Leaflet/OpenStreetMap (EPIC-007), sans conversion ultérieure.
- **Propriétaire** : identifiant stable (slug de compte), pas un e-mail dupliqué — évite une resynchronisation avec EPIC-005 et TASK-004-02-03.
- **Champs partagés vs. par langue** : **non tranché par cette Task**. Grav ne fusionne pas nativement les frontmatters de deux fichiers de langue différents, et aucune pratique n'a été validée techniquement à ce stade. Le schéma ci-dessus s'applique à un seul fichier de page ; le mécanisme de déclinaison multilingue est explicitement renvoyé à EPIC-006.

## Référence complète des champs (TASK-002-01-03)

Table de référence à utiliser directement par FEAT-002-02 (template) et FEAT-002-03 (création des pages), sans avoir à relire l'historique d'analyse ci-dessus.

| Clé | Type | Obligatoire | Exemple | Description |
|---|---|---|---|---|
| `title` | string *(natif Grav)* | Oui | `Le Vieux Colombier` | Nom du gîte, titre de la page. |
| `proprietaire` | string (slug) | Oui | `jean-dupont` | Identifiant stable du compte propriétaire (plugin Login). Ne jamais utiliser un e-mail en clair. |
| `equipements` | liste de string | Non | `[Wifi, Cheminée]` | Liste libre des équipements disponibles. Texte libre, pas de vocabulaire contrôlé (cf. décisions TASK-002-01-02). |
| `capacite_max` | integer | Oui | `6` | Nombre maximal de personnes accueillies. |
| `nombre_chambres` | integer | Oui | `3` | Nombre de chambres. |
| `informations_pratiques` | objet | Non | — | Regroupe les sous-clés ci-dessous. |
| `informations_pratiques.arrivee` | string | Non | `à partir de 16h` | Horaire d'arrivée indicatif. |
| `informations_pratiques.depart` | string | Non | `avant 10h` | Horaire de départ indicatif. |
| `informations_pratiques.animaux_acceptes` | boolean | Non | `false` | Acceptation des animaux. |
| `coordonnees` | objet | Oui | — | Localisation du gîte, exploitée par la carte (EPIC-007). |
| `coordonnees.adresse` | string | Oui | `12 rue Example, 68000 Colmar` | Adresse postale complète. |
| `coordonnees.latitude` | float | Oui | `48.0779` | Latitude décimale. |
| `coordonnees.longitude` | float | Oui | `7.3567` | Longitude décimale. |
| `disponibilites` | objet | Oui *(depuis TASK-003-01-02)* | — | Calendrier de disponibilités. Schéma détaillé dans `docs/model/disponibilites.md` (EPIC-003), volontairement documenté séparément (DT-009 — séparation de responsabilité du plugin Calendrier). |
| `disponibilites.periodes_indisponibles` | liste d'objets | Non (liste vide = entièrement disponible) | `[]` | Voir `docs/model/disponibilites.md`. |

Champs ne relevant **pas** des métadonnées YAML (rappel, cf. « Champs identifiés ») :
- `description` → corps Markdown de la page, pas une clé YAML.
- galerie photographique → fichiers média natifs dans le dossier de la page, pas une clé YAML.

### Exemple complet d'une page de gîte

```markdown
---
title: Le Vieux Colombier

proprietaire: jean-dupont

equipements:
  - Wifi
  - Cheminée
  - Jardin

capacite_max: 6
nombre_chambres: 3

informations_pratiques:
  arrivee: "à partir de 16h"
  depart: "avant 10h"
  animaux_acceptes: false

coordonnees:
  adresse: "12 rue Example, 68000 Colmar"
  latitude: 48.0779
  longitude: 7.3567
---

# Le Vieux Colombier

Description du gîte en texte libre (Markdown), affichée dans le corps de la fiche.
```

## Galerie photographique — format de stockage (TASK-002-04-01)

Formalise la convention déjà appliquée de facto en TASK-002-03-02 (aucun fichier existant à renommer).

- **Format source** : JPEG uniquement pour les photographies de gîte. Format standard, universellement produit par appareils/smartphones, bonne compression. Les formats graphiques (PNG, SVG) restent réservés aux éléments du thème, hors périmètre de la galerie d'un gîte.
- **Nommage** : `photo-N.jpg`, `N` séquentiel à partir de 1.
- **Résolution recommandée** : largeur maximale conseillée de 2000px en entrée. Recommandation à l'attention d'un futur propriétaire important son contenu ; aucune validation ni redimensionnement automatique à ce stade (réservé à TASK-002-04-04).
- **Emplacement** : dossier de la page du gîte concerné (média natif Grav, `page.media()`), sans configuration additionnelle.

### Conformité des fichiers existants

`grav/user/pages/03.gites/01.gite-un/photo-1.jpg`/`photo-2.jpg` et `grav/user/pages/03.gites/02.gite-deux/photo-1.jpg`/`photo-2.jpg` (TASK-002-03-02) respectent déjà ces règles (JPEG, nommage `photo-N.jpg`). **Seuls 2 fichiers physiques existent par gîte à ce jour** — donnée réelle limitée, non bloquante pour la conception (sert justement à valider les comportements de repli ci-dessous), mais insuffisante pour représenter visuellement la présentation complète tant que du contenu réel supplémentaire n'aura pas été fourni.

### TASK-002-04-02 — Ajouter les images dans Grav : déjà satisfaite

Vérification effectuée : `grav/user/config/media.yaml` (utilisateur) est vide, et la configuration système de Grav (`system/config/media.yaml`) prend déjà nativement en charge le type `jpg`/`jpeg` (MIME `image/jpeg`, filtres par défaut), sans nécessiter de surcharge. Combiné aux images déjà présentes et détectées par `page.media()` (TASK-002-03-02), aucune action technique distincte n'était nécessaire pour cette Task. Confirmé avec l'humain — aucune configuration `media.yaml` ajoutée.

## Galerie photographique — modèle de métadonnées (TASK-GAL-00-01)

**Évolution intentionnelle du modèle documenté ci-dessus.** Jusqu'ici, la galerie reposait uniquement sur les fichiers physiques du dossier de page (`page.media()`), sans aucune métadonnée YAML — décision explicite d'origine (TASK-002-04-01/02-04-02, section « Champs identifiés » ci-dessus : « pas un champ YAML dédié »). Cette section fait évoluer consciemment ce choix pour permettre la nouvelle présentation photographique à deux niveaux (`docs/workflow/etude-architecture-galerie-photos-gites.md`), sans remettre en cause le reste du modèle de contenu ni les décisions déjà actées (format JPEG, nommage `photo-N.jpg`, emplacement).

**Ce que cette évolution ne change pas** : aucun nouveau rôle, aucune nouvelle politique d'autorisation. La gestion des photographies (comme le reste du contenu d'un gîte) reste du ressort de l'administrateur, exactement selon les mécanismes d'accès déjà établis (DR-016, TASK-008-04-01) — le propriétaire ne dispose toujours d'aucune capacité de gestion de contenu de gîte, seulement de la gestion de ses disponibilités (DR-012, `/gerer`). L'exposition de ces nouveaux champs dans l'admin Grav (blueprint) fait l'objet d'une Task ultérieure dédiée (TASK-GAL-01-03, `docs/planning/plan-recale-galerie.md`) — un moyen technique d'édition, pas un changement de droits.

### Option retenue : liste centralisée dans le frontmatter (Option A)

Conforme à `docs/workflow/etude-architecture-galerie-photos-gites.md` (section 3.4, Option A) : une liste unique de photos dans le frontmatter du gîte, chaque photo portant un attribut de catégorie. Le texte alternatif est conservé dans cette même structure centralisée (pas de second modèle parallèle).

**Alternative étudiée et écartée** : Grav supporte nativement un fichier `<image>.jpg.meta.yaml` par photo (mécanisme vérifié dans le code source de Grav, `Page/Media.php`), qui aurait pu porter le texte alternatif indépendamment du frontmatter de la page. Écarté pour cette implémentation : cela créerait deux sources de vérité (le frontmatter pour catégorie/ordre/vitrine, un fichier séparé par image pour l'alt), sans bénéfice proportionné pour ce volume de contenu. Le frontmatter reste l'unique source pour toutes les métadonnées de galerie.

### Taxonomie des espaces (catégories fixes)

Liste fixe, dans l'ordre d'affichage (identique pour tous les gîtes, garantit une cohérence de présentation sur l'ensemble du site) :

| Clé | Libellé affiché |
|---|---|
| `salon` | Salon |
| `cuisine` | Cuisine |
| `chambres` | Chambres |
| `salle_de_bain` | Salle de bain |
| `exterieurs` | Extérieurs |
| `autres` | Photos supplémentaires |

`autres` sert de catégorie de repli explicite (une photo peut y être rattachée volontairement — ex. une photo qui ne correspond à aucun espace précis), mais **n'est jamais attribuée automatiquement** (voir « Photos non déclarées » ci-dessous). Le mécanisme technique de centralisation de cette liste (fichier de configuration dédié vs constante Twig, sur le modèle du précédent `mois_fr` de `partials/calendrier.html.twig`) sera tranché en Phase A de TASK-GAL-01-01 — détail d'implémentation, pas une décision structurante.

### Structure de frontmatter

Nouvelle clé `galerie.photos`, liste d'objets :

```yaml
galerie:
  photos:
    - fichier: photo-1.jpg
      alt: "Salon avec vue sur les Vosges"
      espace: salon
      ordre: 1
      vitrine: 1
    - fichier: photo-2.jpg
      alt: "Cuisine équipée, plan de travail en bois"
      espace: cuisine
      ordre: 1
      vitrine: 2
```

| Clé | Type | Obligatoire | Description |
|---|---|---|---|
| `galerie.photos` | liste d'objets | Non (liste vide/absente = pas de galerie affichée) | Liste unique de toutes les photos gérées par la nouvelle présentation. |
| `galerie.photos[].fichier` | string | Oui | Nom du fichier physique dans le dossier de la page (doit correspondre à un fichier réellement présent, détecté via `page.media()`). |
| `galerie.photos[].alt` | string | Oui | Texte alternatif, obligatoire et signifiant. Jamais généré automatiquement à partir du nom de fichier. |
| `galerie.photos[].espace` | string | Oui | Une des clés de la taxonomie ci-dessus. |
| `galerie.photos[].ordre` | integer | Non | Position au sein de sa catégorie. À défaut : ordre de déclaration dans la liste. |
| `galerie.photos[].vitrine` | integer (1 à 5) | Non | Position parmi les 5 photos vitrine de la fiche (1 = grande photo, 2 à 5 = vignettes). Absence = photo non retenue en vitrine par défaut (mais reste éligible au repli, voir ci-dessous). Une même photo peut être à la fois vitrine et affichée dans sa section sur la page « Toutes les photos » — ce n'est pas une exclusion mutuelle. |

### Règles de repli

- **Photo physiquement présente (`page.media()`) mais absente de `galerie.photos`** : **ignorée par la nouvelle galerie**, pas affichée et pas rattachée automatiquement à `autres`. Choix retenu (parmi les deux options laissées ouvertes par l'étude, section 7) : une photo sans entrée dans `galerie.photos` n'a par définition ni texte alternatif ni catégorie déclarés — l'afficher quand même violerait l'exigence d'accessibilité (alt jamais généré automatiquement). Comportement simple et prévisible : seules les photos explicitement décrites apparaissent.
- **Moins de 5 photos marquées `vitrine`** : la sélection est complétée automatiquement avec les premières photos de `galerie.photos` (dans l'ordre de déclaration) non déjà retenues, jusqu'à 5 ou jusqu'à épuisement de la liste.
- **Moins de 5 photos au total dans `galerie.photos`** : la grille d'aperçu affiche uniquement les photos disponibles (1 à 4), sans case vide. Avec une seule photo, seule la grande photo s'affiche (pas de vignettes).
- **Zéro photo dans `galerie.photos`** : la section galerie ne s'affiche pas du tout sur la fiche (cohérent avec le comportement actuel `{% if ... is not empty %}`).
- **Catégorie sans aucune photo pour un gîte donné** : la section correspondante ne s'affiche pas sur la page « Toutes les photos » de ce gîte (pas de titre de section vide).
- **Métadonnée `alt` absente pour une photo par ailleurs déclarée** (erreur de saisie) : repli défensif sur un texte neutre (ex. « Photographie du gîte »), uniquement comme filet de sécurité technique — ne dispense pas de renseigner un texte alternatif réel, qui reste obligatoire en pratique.

### État des deux gîtes réels

`gite-un` et `gite-deux` n'ont pas encore de clé `galerie.photos` renseignée (2 fichiers physiques chacun, non déclarés). Leur ajout, sur ces 2 gîtes réels, fait l'objet de TASK-GAL-01-02 (`docs/planning/plan-recale-galerie.md`).

## Processus de validation avant publication (TASK-008-04-01)

Conforme à DR-016 (« processus de validation des nouveaux gîtes ») et à la clarification actée avec l'utilisateur (2026-07-20) : les fiches de gîtes sont créées directement par l'administrateur (comme `gite-un`/`gite-deux` depuis l'origine du projet) — aucun propriétaire ne soumet sa propre fiche. Le processus de validation se réduit donc à l'usage du champ natif Grav `published`.

**Vérifié empiriquement** (page de test créée puis supprimée via l'API admin, aucune trace résiduelle) :

- `published: false` dans le frontmatter → la page retourne **404 côté public** (confirmé en HTTP réel), tout en restant pleinement consultable et modifiable par l'administrateur via admin2.
- Passage à `published: true` (ou suppression de la clé, `true` étant la valeur par défaut) → la page devient immédiatement accessible publiquement (confirmé en HTTP réel, 200).

**Workflow de validation recommandé** : lors de l'ajout d'un nouveau gîte, l'administrateur crée la page avec `published: false`, la complète (contenu, photos, coordonnées, propriétaire associé), puis la publie explicitement (`published: true`) une fois la validation effectuée — sans nécessiter de développement applicatif supplémentaire.

Aucune donnée `publish_date`/`unpublish_date` (publication programmée) n'est nécessaire pour ce besoin : la validation est un acte manuel de l'administrateur, pas une planification temporelle.

## Explicitement hors périmètre de cette identification

Ces éléments concernent la fiche de gîte mais relèvent d'autres Features/Epics et ne sont pas anticipés ici :

- **Disponibilités / calendrier** — FEAT-003-01 *« étendra »* explicitement cette structure YAML une fois EPIC-003 atteint.
- **Champs du formulaire de contact** — FEAT-004-01.
- **Rendu technique de la galerie** (format de stockage, optimisation) — FEAT-002-04.
- **Déclinaison multilingue des champs** — EPIC-006.

## Observations pour les Tasks futures

*(Constats issus de l'analyse, non traités ici, à considérer lors des Tasks concernées.)*

- ~~Format du champ « caractéristiques / équipements »~~ — **tranché en TASK-002-01-02** (liste de texte libre, cf. section « Structure YAML »).
- ~~Format des coordonnées de localisation~~ — **tranché en TASK-002-01-02** (latitude/longitude décimales + adresse).
- ~~Format de la référence « propriétaire »~~ — **tranché en TASK-002-01-02** (identifiant stable, pas d'e-mail).
- **Champs partagés vs. déclinables par langue** — **toujours ouvert**, explicitement renvoyé à EPIC-006 (aucune pratique Grav validée techniquement à ce stade pour fusionner les frontmatters entre fichiers de langue).
- *(Nouvelle observation, EPIC-005)* : le champ `proprietaire: slug-du-compte` suppose que le slug de compte du plugin Login sera connu et stable avant la création des premières pages de gîtes (TASK-002-03-01). À vérifier lors de FEAT-001-02/EPIC-005 : l'ordre de création des comptes propriétaires vs. des pages de gîtes n'est pas explicitement contraint par le plan.
