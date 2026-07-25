# Conventions Twig

## Objectif

Assurer une structure homogène des templates du thème `gites-theme`, cohérente avec le thème parent `quark2` dont il hérite, et éviter que des Tasks différentes produisent des organisations divergentes.

## Règles

### Emplacement des templates

- Tous les templates propres au projet vivent sous `grav/user/themes/gites-theme/templates/`.
- Un template n'est créé dans `gites-theme/templates/` que s'il doit réellement surcharger ou compléter un template de `quark2` (héritage via `extends@: quark2`, cf. `gites-theme.yaml`). Ne pas dupliquer un template de `quark2` sans modification réelle.
- Organisation interne alignée sur la convention déjà utilisée par `quark2` :
  - `templates/partials/` — fragments réutilisables (ex. carte d'un gîte, extrait de calendrier).
  - `templates/modular/` — templates de pages modulaires, si utilisés.
  - Un template de premier niveau par type de page (ex. `gite-item.html.twig`, `gite-list.html.twig`), à l'image de `default.html.twig` / `item.html.twig` dans `quark2`.

### Nommage

- Noms de fichiers en `kebab-case`, en anglais technique (cohérent avec les conventions Grav natives : `gite-item.html.twig`, pas `FicheGite.twig`).
- Le nom du fichier reflète le type de contenu affiché, pas la Task qui l'a créé.

### Blocs Twig

- Réutiliser les blocs déjà définis par `quark2` (`{% block content %}`, etc.) plutôt que d'en redéfinir de nouveaux sans nécessité, pour bénéficier de l'héritage.
- Un bloc surchargé doit rester limité à ce qui doit réellement changer ; ne pas recopier tout le contenu du bloc parent si seule une partie doit être modifiée.

### Internationalisation

- Aucun texte affiché ne doit être codé en dur dans un template : passer par le système de traduction natif de Grav (`{{ 'CLE'|t }}`), avec les clés définies dans les fichiers de langue du thème (FR par défaut, DE ensuite — cf. `docs/context/constraints.md`).

### Logique métier

- Un template Twig ne contient pas de logique métier (calcul de disponibilités, validation, etc.) : cette logique appartient au plugin concerné (ex. futur plugin calendrier) ou au thème PHP, jamais au template lui-même.

## Contenu attendu (à titre indicatif, non figé)

Chaque nouveau template doit rester le plus court possible, s'appuyer sur l'héritage de `quark2`, et ne surcharger que ce qui est explicitement demandé par la Task en cours.

### Nommage des partials de galerie photographique (TASK-GAL-00-02)

- `partials/galerie-apercu.html.twig` — grille d'aperçu de la fiche (1 grande photo + 4 vignettes).
- `partials/galerie-section.html.twig` — une section (espace) de la page « Toutes les photos », réutilisé une fois par catégorie présente.
- Pas de partial séparé pour le bouton de retour : un simple lien `<a>`, trop court pour justifier un composant dédié (cohérent avec « Contenu attendu » ci-dessous — rester le plus court possible).

### Grilles CSS

- Les grilles de la galerie (aperçu sur la fiche, sections de la page « Toutes les photos ») utilisent `display: grid` natif, sans framework CSS supplémentaire — cohérent avec `docs/context/constraints.md` (CSS simple) et avec la pratique déjà en place (`gites-theme/css/custom.css`, ex. `.calendrier-table-wrapper`).

### Images responsives et performance

- Les images de la galerie utilisent `srcset`/`sizes` (moteur de redimensionnement natif de Grav) plutôt qu'une taille unique fixe, pour éviter de servir une image plus grande que sa taille d'affichage réelle.
- `loading="lazy"` sur toutes les images de la galerie, **sauf** la grande photo de la fiche (candidate au LCP — Largest Contentful Paint), qui charge en priorité et peut porter `fetchpriority="high"`.
- Dimensions explicites (`width`/`height` ou `aspect-ratio` CSS) sur chaque image, pour éviter tout décalage de mise en page (CLS — Cumulative Layout Shift).

## Moment d'utilisation

Dès la première Task créant ou modifiant un template (typiquement FEAT-002-02 — création du template de fiche de gîte), et à chaque Task suivante touchant l'affichage. Les règles de galerie ci-dessus s'appliquent à partir de TASK-GAL-02-01 (premier partial de galerie créé).
