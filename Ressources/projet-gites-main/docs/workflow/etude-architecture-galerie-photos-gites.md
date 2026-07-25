# Étude d'architecture — Présentation des photographies des gîtes
**Projet Grav — Galerie inspirée d'Airbnb (version simplifiée)**

---

## 1. Analyse UX

### Ce qui est conservé du modèle Airbnb

- **La grille "hero" en 2 niveaux** : une grande photo à gauche, quatre vignettes à droite. C'est le cœur du repère visuel Airbnb — il donne immédiatement une impression de volume et de qualité du logement sans surcharger la fiche.
- **Le bouton "Voir toutes les photos"** positionné sur la dernière vignette, qui signale clairement qu'il existe plus de contenu.
- **Le clic universel** : n'importe quelle photo de la grille ouvre la même destination (la page complète), ce qui simplifie la logique d'interaction — un seul comportement à retenir pour l'utilisateur.
- **Le regroupement des photos par espace** (Salon, Cuisine, Chambres...) sur la page dédiée, qui aide à la projection ("je veux voir la salle de bain") plutôt qu'un défilement chronologique brut.
- **Un chemin de retour explicite** vers la fiche.

### Ce qui est volontairement simplifié

- **Pas de lightbox / visualiseur plein écran.** Chez Airbnb, cliquer sur une photo dans la page "Toutes les photos" ouvre un carrousel plein écran avec navigation clavier, zoom, compteur, etc. Ici, ce mécanisme disparaît complètement : la page "Toutes les photos" est le point d'arrivée final.
- **Pas de carrousel tactile sur la fiche.** Airbnb propose un swipe mobile sur la grande photo en page fiche ; ici, la fiche reste statique (5 photos fixes), tout le reste se passe sur la page dédiée.
- **Pas de préchargement dynamique / infinite scroll.** La page "Toutes les photos" est un rendu statique groupé par section, sans pagination ni chargement asynchrone.
- **Pas de système de tags multiples ou de filtres** (Airbnb permet parfois de filtrer par catégorie sur la page photos) — ici uniquement un classement fixe par section.

### Impact sur l'expérience utilisateur

- **Gain** : complexité de développement et de maintenance très réduite, temps de chargement plus prévisible, accessibilité plus simple à garantir (pas de piège au clavier propre aux lightbox).
- **Perte modérée** : l'utilisateur qui veut "zoomer" sur une photo précise ou naviguer photo par photo en plein écran ne le pourra pas. Pour un site de gîtes (peu de photos, décision d'achat plutôt que exploration infinie comme Airbnb), cette perte est mineure : l'enjeu principal est de donner une vue d'ensemble crédible et rassurante, pas une expérience immersive de type catalogue e-commerce.
- **Cohérence conservée** : le parcours mental de l'utilisateur (aperçu → "voir plus" → vue organisée par pièce → retour) reste identique à celui d'Airbnb, donc aucun effort d'apprentissage supplémentaire pour un public habitué à ce standard.

---

## 2. Architecture fonctionnelle

### 2.1 Les deux pages

**Page A — Fiche du gîte** (page existante, enrichie)
- Bloc "galerie d'aperçu" en haut de fiche : 1 grande photo + 4 vignettes.
- Aucune autre modification de la fiche n'est requise par ce périmètre.

**Page B — "Toutes les photos"**
- Page autonome, dédiée uniquement aux photos du gîte concerné.
- Structure : en-tête avec flèche de retour (+ éventuellement le nom du gîte), puis une suite de sections, une par espace, chacune affichant la totalité des photos de cet espace en grille.
- Pas de sous-navigation complexe : un simple défilement vertical suffit (éventuellement une ancre de sommaire, voir 2.4).

### 2.2 Parcours utilisateur

1. L'utilisateur arrive sur la fiche du gîte.
2. Il voit la grille de 5 photos avec le lien "Voir toutes les photos" superposé à la 5e vignette.
3. Il clique sur n'importe quelle photo **ou** sur le lien → redirection vers la page B, dédiée à ce gîte.
4. Il parcourt les sections par espace (Salon, Cuisine, Chambres, etc.).
5. Il clique sur la flèche de retour → il revient à la fiche du gîte (au même point de scroll si possible, cf. 2.4).

Ce parcours est **linéaire et sans embranchement**, ce qui est un choix délibéré de simplicité.

### 2.3 Navigation

- **Fiche → Page photos** : lien direct, une seule route par gîte (ex. `/gites/nom-du-gite/photos`).
- **Page photos → Fiche** : bouton retour. Deux options possibles :
  - lien simple vers l'URL de la fiche (le plus robuste, indépendant de l'historique navigateur) ;
  - `history.back()` en JS si l'on veut restituer la position de scroll d'origine — à documenter comme choix technique, pas obligatoire.
- Pas de navigation interne complexe entre sections : un sommaire d'ancrage (liens "Salon / Cuisine / Chambres…" en haut de page qui scrollent vers la section) est une amélioration possible mais non indispensable.

### 2.4 Responsive (desktop / tablette / mobile)

**Fiche — grille 1 grande + 4 petites**
- *Desktop* : grille 2 colonnes (grande photo à gauche occupant ~50 %, 4 vignettes en 2x2 à droite), hauteur fixe harmonisée, coins arrondis.
- *Tablette* : même logique en réduisant les proportions, ou passage à une grande photo + 2x2 plus compact selon largeur disponible.
- *Mobile* : la grille 5 photos n'est plus pertinente visuellement. On bascule sur une **seule photo principale** (la première) avec le bouton "Voir toutes les photos" affiché en overlay ou juste en dessous. Un léger indicateur (ex. "1/5") peut suffire, sans carrousel obligatoire pour rester dans l'esprit "simplifié".

**Page "Toutes les photos" — grille par section**
- *Desktop* : grille de 3 à 4 colonnes par section.
- *Tablette* : grille de 2 colonnes.
- *Mobile* : grille de 1 à 2 colonnes selon le nombre de photos, empilement vertical des sections.
- La flèche de retour reste fixe ou sticky en haut de page sur mobile, pour rester accessible après un long scroll.

### 2.5 Règles d'affichage

- Une photographie doit toujours avoir un **espace/catégorie** assigné ; une catégorie "Photos supplémentaires" sert de repli pour toute photo non catégorisée.
- L'ordre des sections est fixe et défini par le site (pas dépendant de l'ordre d'upload), pour garantir une cohérence entre tous les gîtes.
- L'ordre des photos à l'intérieur d'une section suit l'ordre défini dans les données (cf. section 3).
- Si un gîte a moins de 5 photos, la grille de la fiche s'adapte (voir cas limites en section 7).
- Le ratio des images (crop) doit être cohérent au sein d'une même grille pour un rendu propre.

---

## 3. Modèle de données (Grav)

Grav n'a pas de base de données : tout repose sur le frontmatter YAML des pages et l'organisation des fichiers médias dans le dossier de la page.

### 3.1 Principe général

Chaque gîte est une page Grav (ex. `01.gites/gite-la-grange/`). Le dossier de page contient déjà les médias physiques. On ajoute dans le frontmatter une structure qui **associe chaque fichier média à une catégorie d'espace** et à des métadonnées d'affichage.

### 3.2 Catégories d'espaces (taxonomie fixe)

Proposition de liste standard, réutilisable pour tous les gîtes :

- `salon`
- `cuisine`
- `chambres`
- `salle_de_bain`
- `exterieurs`
- `autres` (correspond à "Photos supplémentaires", catégorie de repli)

Cette liste peut être centralisée dans un fichier de configuration Grav (`data/gites_categories.yaml` ou équivalent) plutôt que redéfinie dans chaque page, afin de garantir :
- un ordre d'affichage unique et cohérent sur tout le site ;
- des libellés traduisibles/modifiables en un seul endroit ;
- une validation possible des catégories utilisées dans le frontmatter (éviter les fautes de frappe créant une catégorie fantôme).

### 3.3 Métadonnées nécessaires par photo

Pour chaque photo, on a besoin au minimum de :

- **fichier** : nom du fichier média dans le dossier de page ;
- **catégorie/espace** : une des valeurs de la taxonomie ci-dessus ;
- **texte alternatif (alt)** : obligatoire pour l'accessibilité, ne doit pas être généré automatiquement à partir du nom de fichier ;
- **ordre** : position au sein de sa catégorie (entier, ou simplement l'ordre de déclaration dans le frontmatter) ;
- **mise en avant** (optionnel) : un booléen ou une position permettant de désigner laquelle des photos sert de "grande photo" et lesquelles servent de "4 vignettes" sur la fiche, indépendamment de leur catégorie.

### 3.4 Organisation proposée dans le frontmatter

Deux approches possibles, à trancher en fonction des habitudes de l'équipe :

**Option A — Liste unique de photos avec attribut de catégorie**
Chaque photo est un item d'une liste unique, avec un champ indiquant sa catégorie. C'est la structure la plus simple à maintenir et la plus proche du fonctionnement natif de Grav (proche de la collection `media`). Le classement par section pour la page "Toutes les photos" se fait par un regroupement (filtre) effectué côté template, pas côté données.

**Option B — Structure pré-groupée par catégorie**
Le frontmatter contient directement une entrée par catégorie, chacune listant ses photos. Plus lisible "à l'œil" pour l'auteur du contenu, mais duplique la notion de catégorie (clé + valeur), et rend plus délicat le choix des 5 photos "vitrine" de la fiche (il faut alors piocher dans plusieurs groupes).

**Recommandation** : Option A (liste unique avec attribut catégorie), car elle simplifie la sélection des 5 photos vitrine (on peut simplement marquer 5 photos comme "vitrine" indépendamment de leur catégorie) et rend le regroupement par section une simple opération d'affichage, réversible et sans duplication de données.

### 3.5 Lien avec les médias physiques

Grav expose nativement les fichiers du dossier de page via l'objet `page.media`. La structure de frontmatter proposée ne duplique pas les fichiers : elle **annote** les noms de fichiers déjà présents dans le dossier. Toute photo présente physiquement mais absente du frontmatter peut être traitée par une règle de repli (ex. rattachée automatiquement à "Photos supplémentaires") — point à trancher en section 7.

---

## 4. Intégration Grav

### 4.1 Templates Twig concernés

- **Template de fiche gîte** (existant) : ajout d'un bloc/partial "galerie d'aperçu" inséré en haut de la fiche.
- **Nouveau template de page "Toutes les photos"** : soit un template de page Grav dédié (ex. `gite-photos.html.twig`) associé à une sous-page ou une route virtuelle du gîte, soit une modale/route générée dynamiquement selon l'architecture de routes déjà en place sur le site. Le choix dépend de la façon dont les gîtes sont actuellement routés (pages Grav classiques vs génération dynamique) — point à confirmer avec l'équipe technique avant le découpage en tâches.

### 4.2 Composants (partials Twig) à créer

- `partials/galerie-apercu.html.twig` : rendu de la grille 1 grande + 4 vignettes + lien "Voir toutes les photos", avec sa variante responsive mobile (1 photo + bouton).
- `partials/galerie-section.html.twig` : rendu d'une section (titre d'espace + grille de photos), réutilisé autant de fois que de catégories présentes.
- `partials/bouton-retour.html.twig` (optionnel, peut être un composant générique déjà existant sur le site) : flèche + lien de retour.

Ces partials reçoivent en entrée la structure de données décrite en section 3 (déjà filtrée/groupée par la logique du template parent), pour rester simples et sans logique métier interne.

### 4.3 Assets CSS

- Une feuille de style dédiée à la galerie (grille CSS native `display: grid`, sans framework supplémentaire nécessaire) :
  - grille fiche (2 colonnes desktop / 1 colonne mobile) ;
  - grille par section sur la page photos (grille responsive avec `auto-fill`/`minmax` pour éviter des media queries multiples) ;
  - styles du bouton "Voir toutes les photos" et de la flèche de retour.
- Réutilisation autant que possible des variables de style déjà existantes sur le site (couleurs, rayons de bordure, ombres) pour rester cohérent visuellement avec le reste du thème Grav.

### 4.4 JavaScript (minimum nécessaire)

Le périmètre défini (pas de lightbox, pas de carrousel plein écran) permet de réduire le JavaScript au strict minimum, voire de s'en passer complètement :

- **Aucun JS obligatoire** pour l'affichage ou la navigation (tout repose sur des liens `<a>` classiques).
- **JS optionnel** si l'on souhaite :
  - un sommaire d'ancrage avec défilement fluide (`scroll-behavior: smooth` en CSS suffit généralement, sans JS) ;
  - la restitution de la position de scroll au retour (`history.back()`) ;
  - un léger indicateur "1/5" sur la version mobile de la fiche.

Recommandation : ne rien coder en JS dans une première itération, tout est faisable en HTML/CSS pur.

---

## 5. Performances

- **Formats d'image modernes** : servir les photos en WebP (voire AVIF si le pipeline le permet), avec fallback JPEG si nécessaire selon le support navigateur visé.
- **Responsive images natives** : utiliser `srcset` / `sizes` (Grav dispose nativement de fonctions de redimensionnement d'image dans son moteur de médias) pour ne jamais envoyer une image plus grande que sa taille d'affichage réelle.
- **Lazy loading natif** : attribut `loading="lazy"` sur toutes les images sauf la grande photo principale de la fiche (celle-ci doit charger en priorité, potentiellement avec `fetchpriority="high"`, car elle est visible immédiatement — c'est généralement l'élément candidat au LCP - Largest Contentful Paint).
- **Dimensions explicites** : toujours renseigner `width`/`height` (ou un ratio via CSS `aspect-ratio`) sur chaque image pour éviter tout décalage de mise en page (CLS - Cumulative Layout Shift).
- **Pas de JS bloquant** : en l'absence de lightbox, aucun script lourd n'est nécessaire au chargement, ce qui limite naturellement l'impact sur le FID/INP (Interaction to Next Paint).
- **Poids des vignettes** : les 4 petites photos de la fiche peuvent être servies dans une résolution nettement inférieure à celle utilisée sur la page "Toutes les photos", puisqu'elles ne sont jamais affichées en grand sur la fiche.

---

## 6. Accessibilité

- **Texte alternatif** obligatoire et signifiant pour chaque photo (renseigné en donnée, jamais généré automatiquement).
- **Navigation clavier** : tous les éléments cliquables (photos de la grille, bouton "Voir toutes les photos", flèche de retour) doivent être de vrais éléments focusables (`<a>` ou `<button>`), jamais des `<div>` avec gestionnaire de clic seul.
- **Structure de titres cohérente** : chaque section de la page "Toutes les photos" doit utiliser un vrai titre HTML (`h2` par exemple) pour permettre la navigation par lecteur d'écran via les raccourcis de titres.
- **Bouton retour explicite** : libellé clair (pas seulement une icône), avec un `aria-label` si l'icône seule est utilisée visuellement.
- **Contraste** : le lien "Voir toutes les photos" superposé à une photo doit respecter un contraste suffisant (fond semi-opaque derrière le texte si nécessaire).
- **Absence de piège au clavier** : ce point, généralement critique dans une lightbox, disparaît naturellement ici puisqu'aucun visualiseur modal n'est prévu — c'est un des bénéfices indirects de la simplification demandée.
- **Ordre de tabulation logique** : suivre l'ordre visuel (grande photo puis les 4 vignettes puis le bouton) dans le DOM.

---

## 7. Difficultés techniques / points sensibles

- **Nombre de photos insuffisant** : que faire si un gîte a moins de 5 photos au total ? Il faut définir une règle de repli pour la grille d'aperçu (ex. dupliquer visuellement, agrandir la grande photo, masquer les vignettes manquantes) plutôt que de laisser des cases vides.
- **Gîte sans photo dans une catégorie** : certaines sections (ex. "Salle de bain") peuvent être vides pour un gîte donné — la section correspondante ne doit simplement pas s'afficher, ce qui doit être anticipé dans le template (test de présence avant rendu).
- **Photos non catégorisées** : définir clairement si une photo présente sur le disque mais absente du frontmatter est ignorée, ou automatiquement classée en "Photos supplémentaires" — ce choix a un impact sur la simplicité de saisie pour les administrateurs du contenu.
- **Cohérence des recadrages (crop)** : sur la fiche, les 5 photos doivent avoir un rendu visuellement homogène (même ratio) même si les fichiers sources ont des ratios différents à l'origine ; cela implique une politique de recadrage automatique (`object-fit: cover`) plutôt qu'un simple redimensionnement.
- **Choix des 5 photos "vitrine"** : décider si elles sont choisies manuellement par l'administrateur (champ dédié) ou automatiquement (les 5 premières de la liste) — impacte directement la structure de données retenue en section 3.
- **Routing Grav** : selon l'architecture actuelle du site (pages Grav "physiques" vs génération dynamique de routes), la création de la page "Toutes les photos" comme sous-page Grav standard ou comme route virtuelle générée à la volée peut demander un arbitrage technique préalable.
- **Cohérence multi-gîtes** : s'assurer que la taxonomie des catégories (section 3.2) reste identique sur tous les gîtes du site, pour que le composant de section soit réellement générique et réutilisable sans configuration spécifique par gîte.

---

## 8. Proposition de découpage (Features uniquement)

> Ce découpage liste des Features et sous-Features. Aucune Task n'est produite : le détail des tâches sera réalisé séparément.

### Feature 1 — Modèle de données des photographies
- Sous-feature 1.1 : Définition de la taxonomie des espaces (catégories fixes, config centralisée)
- Sous-feature 1.2 : Structure de frontmatter pour associer photos, catégories et métadonnées
- Sous-feature 1.3 : Règles de repli (photo non catégorisée, gîte avec peu de photos)

### Feature 2 — Galerie d'aperçu sur la fiche du gîte
- Sous-feature 2.1 : Sélection des 5 photos vitrine (grande photo + 4 vignettes)
- Sous-feature 2.2 : Rendu responsive de la grille (desktop / tablette / mobile)
- Sous-feature 2.3 : Bouton/lien "Voir toutes les photos" avec comportement de clic universel sur les 5 photos

### Feature 3 — Page "Toutes les photos"
- Sous-feature 3.1 : Structure de la page (en-tête, flèche de retour)
- Sous-feature 3.2 : Regroupement et affichage des photos par section
- Sous-feature 3.3 : Rendu responsive des grilles de section (desktop / tablette / mobile)
- Sous-feature 3.4 : Navigation retour vers la fiche du gîte

### Feature 4 — Intégration Grav (templates & composants)
- Sous-feature 4.1 : Partial "galerie d'aperçu"
- Sous-feature 4.2 : Partial "section de photos"
- Sous-feature 4.3 : Template de la page "Toutes les photos" et intégration au routing existant

### Feature 5 — Performance & optimisation des images
- Sous-feature 5.1 : Génération d'images responsives (srcset/sizes, formats modernes)
- Sous-feature 5.2 : Lazy loading et priorisation de la photo principale (LCP)
- Sous-feature 5.3 : Prévention des décalages de mise en page (dimensions/ratio explicites)

### Feature 6 — Accessibilité
- Sous-feature 6.1 : Textes alternatifs et structure sémantique (titres, liens, boutons)
- Sous-feature 6.2 : Navigation clavier et focus
- Sous-feature 6.3 : Contraste et lisibilité des éléments superposés (bouton sur photo)

### Feature 7 — Habillage visuel (CSS)
- Sous-feature 7.1 : Styles de la grille d'aperçu (fiche)
- Sous-feature 7.2 : Styles des sections et grilles de la page "Toutes les photos"
- Sous-feature 7.3 : Cohérence avec la charte graphique existante du site

---

*Document destiné à être transmis pour découpage détaillé en Tasks.*
