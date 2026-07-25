Feature 0 — Mise à jour documentaire préalable

    Ces tâches sont obligatoires avant tout développement. Elles assurent que la documentation technique reflète les nouvelles décisions avant la mise en œuvre.

TASK-000-01-01

    Titre : Mettre à jour le modèle de données Grav (documentation)

    Objectif : Ajouter dans la documentation technique la nouvelle structure frontmatter et la taxonomie des espaces définies en section 3.

    Description détaillée :

        Ajouter un chapitre décrivant la taxonomie fixe (salon, cuisine, chambres, salle_de_bain, exterieurs, autres).

        Préciser l'emplacement centralisé de la liste (ex. data/gites_categories.yaml).

        Documenter l'Option A retenue (liste unique de photos avec attribut de catégorie) avec un exemple YAML complet.

        Spécifier les métadonnées obligatoires (fichier, catégorie, alt, ordre) et optionnelles (mise en avant).

    Dépendances : aucune.

    Fichiers concernés :

        docs/data-model.md (ou équivalent)

        docs/frontmatter-examples.md (à créer si inexistant)

    Critères d'acceptation :

        La structure YAML est documentée avec un exemple réaliste.

        La liste des catégories est clairement listée et justifiée.

        La règle de choix Option A est explicitée.

        Le document est relu et validé par l'équipe technique.

TASK-000-01-02

    Titre : Mettre à jour les conventions de développement du thème

    Objectif : Ajouter les conventions relatives aux partials Twig et aux classes CSS pour la galerie.

    Description détaillée :

        Documenter le nommage des partials (ex. galerie-apercu, galerie-section, bouton-retour).

        Préciser que les grilles utilisent display: grid sans framework.

        Ajouter la règle d'utilisation des images responsive avec srcset / sizes.

        Documenter le recours au lazy loading et à fetchpriority.

    Dépendances : TASK-000-01-01.

    Fichiers concernés :

        docs/conventions-theme.md (ou équivalent)

    Critères d'acceptation :

        Les règles de nommage sont fixées.

        La politique d'utilisation des images (formats, responsive, lazy loading) est écrite.

        Le document est accessible à tout développeur.

Feature 1 — Modèle de données des photographies
TASK-001-01-01

    Titre : Définir la taxonomie des espaces dans un fichier de configuration centralisé

    Objectif : Créer le fichier YAML centralisé contenant la liste des catégories d'espaces.

    Description détaillée :

        Créer user/data/gites_categories.yaml (ou user/config/gites/categories.yaml selon la pratique Grav).

        Définir la liste : salon, cuisine, chambres, salle_de_bain, exterieurs, autres.

        Associer à chaque catégorie un libellé lisible (ex. "Salon", "Cuisine", "Chambres", "Salle de bain", "Extérieurs", "Photos supplémentaires").

        Garantir que l'ordre de déclaration dans ce fichier sera l'ordre d'affichage (section 3.2).

        Ajouter éventuellement une clé enabled: true pour activation/désactivation future (optionnel).

    Dépendances : TASK-000-01-01.

    Fichiers concernés :

        user/data/gites_categories.yaml

        éventuellement user/config/site.yaml si intégration dans la config principale

    Critères d'acceptation :

        Le fichier est créé et syntaxiquement valide.

        Les catégories sont exactement celles du document.

        Le fichier est référençable dans les templates Twig via config.get() ou data.

TASK-001-02-01

    Titre : Ajouter les métadonnées frontmatter à un gîte existant (exemple test)

    Objectif : Enrichir un gîte existant avec la nouvelle structure de données pour validation.

    Description détaillée :

        Choisir un gîte existant (ex. user/pages/01.gites/gite-la-grange/).

        Créer ou modifier le frontmatter selon l'Option A.

        Associer 5 à 10 photos physiquement présentes avec leurs métadonnées (fichier, catégorie, alt, ordre).

        Marquer 5 photos comme "vitrine" via une clé featured: true ou un champ order_vitrine: 1..5 (à définir).

        S'assurer que les noms de fichiers correspondent exactement à ceux présents dans le dossier page.media.

    Dépendances : TASK-001-01-01, TASK-000-01-01.

    Fichiers concernés :

        user/pages/01.gites/gite-la-grange/gite-la-grange.md

        user/pages/01.gites/gite-la-grange/ (photos)

    Critères d'acceptation :

        Le frontmatter est valide YAML.

        Les photos sont bien associées aux catégories.

        Les photos "vitrine" sont identifiables.

        La lecture de page.frontmatter donne la structure attendue.

TASK-001-02-02

    Titre : Documenter la règle de repli pour les photos non catégorisées

    Objectif : Définir et documenter le comportement par défaut pour les photos sans catégorie.

    Description détaillée :

        Spécifier qu'une photo présente dans page.media mais absente du frontmatter sera automatiquement classée dans la catégorie "autres" (section 7).

        Ajouter un commentaire dans le template Twig ou une note technique.

        Mettre à jour la documentation correspondante.

    Dépendances : TASK-001-02-01.

    Fichiers concernés :

        Documentation projet (si applicable)

        docs/data-model.md

    Critères d'acceptation :

        Le comportement de repli est clairement documenté.

        L'équipe a validé cette règle (cf. section 7).

TASK-001-03-01

    Titre : Définir les règles d'affichage pour les gîtes avec moins de 5 photos

    Objectif : Établir les règles de repli pour la grille d'aperçu (section 7).

    Description détaillée :

        Définir le comportement :

            Si moins de 5 photos, la grande photo s'affiche seule ou avec les vignettes disponibles.

            Ne pas créer de cases vides.

        Documenter cette règle dans un commentaire Twig ou une note.

        Le choix final (agrandir la grande photo ou afficher une grille réduite) doit être validé.

    Dépendances : TASK-001-02-01.

    Fichiers concernés :

        Documentation technique

    Critères d'acceptation :

        La règle est définie et validée.

        Un test manuel sur un gîte à 1, 3 et 5 photos est décrit pour validation ultérieure.

Feature 2 — Galerie d'aperçu sur la fiche du gîte
TASK-002-01-01

    Titre : Créer le partial Twig "galerie d'aperçu" (structure HTML de base)

    Objectif : Créer le fichier galerie-apercu.html.twig avec la structure HTML statique.

    Description détaillée :

        Créer themes/gites-theme/templates/partials/galerie-apercu.html.twig.

        Y intégrer la structure de grille : une grande photo (colonne gauche) et une grille 2×2 pour les 4 vignettes (colonne droite).

        Ajouter un lien <a> sur chaque photo pointant vers la route générique (ex. /gites/nom-du-gite/photos).

        Ajouter le bouton/lien "Voir toutes les photos" superposé sur la 5e vignette (ou en remplacement si vignette absente).

        Ne pas coder les styles CSS à ce stade, uniquement la structure Twig/HTML.

    Dépendances : TASK-001-02-01.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

    Critères d'acceptation :

        Le fichier existe dans le bon répertoire.

        La structure HTML reprend la grille documentée.

        Les liens pointent vers une URL logique (même si la page cible n'existe pas encore).

TASK-002-01-02

    Titre : Récupérer et ordonner les 5 photos vitrine dans le partial

    Objectif : Implémenter la logique de sélection des 5 photos vitrine (section 3.3, 3.5).

    Description détaillée :

        Dans le partial, lire le frontmatter du gîte.

        Filtrer les photos marquées "vitrine" (via un champ dédié, ex. featured).

        Si moins de 5 photos sont marquées, compléter avec les premières photos de la liste (dans l'ordre de déclaration).

        Ordonner les 5 photos selon l'ordre défini (champ order_vitrine ou ordre de déclaration).

        Assigner la première photo à la grande colonne, les 4 suivantes aux vignettes.

    Dépendances : TASK-002-01-01.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

    Critères d'acceptation :

        Les 5 bonnes photos s'affichent.

        L'ordre respecte la logique définie.

        En cas de modification des données, la sélection se met à jour.

TASK-002-01-03

    Titre : Gérer le cas d'un gîte avec moins de 5 photos

    Objectif : Implémenter la règle de repli pour les gîtes à moins de 5 photos (section 7).

    Description détaillée :

        Ajouter dans le partial une condition sur le nombre de photos.

        Si N < 5, afficher la grande photo seule ou avec N-1 vignettes.

        Ne pas afficher de cases vides.

        Pour N = 1, masquer les 4 vignettes et n'afficher que la grande photo.

    Dépendances : TASK-002-01-02.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

    Critères d'acceptation :

        Les gîtes à 1, 3 et 5 photos s'affichent correctement.

        Aucune case vide n'apparaît.

TASK-002-02-01

    Titre : Ajouter les styles CSS de la grille d'aperçu (desktop)

    Objectif : Appliquer la mise en page desktop (2 colonnes) selon section 2.4.

    Description détaillée :

        Dans themes/gites-theme/css/gallery.css (ou fichier existant), ajouter les styles pour la grille desktop.

        Utiliser display: grid avec grid-template-columns: 1fr 1fr.

        Fixer une hauteur harmonisée pour toutes les photos (ex. 400px).

        Appliquer object-fit: cover pour un recadrage homogène.

        Ajouter des coins arrondis.

    Dépendances : TASK-002-01-02.

    Fichiers concernés :

        themes/gites-theme/css/gallery.css

        themes/gites-theme/css/style.css (pour l'import)

    Critères d'acceptation :

        La grille desktop s'affiche en 2 colonnes avec les bonnes proportions.

        Les images sont recadrées uniformément.

        Le rendu est cohérent avec la charte graphique.

TASK-002-02-02

    Titre : Adapter la grille d'aperçu pour le responsive mobile

    Objectif : Rendre la grille mobile-friendly selon section 2.4.

    Description détaillée :

        Ajouter un media query pour les écrans ≤ 768px.

        Passer en une seule colonne : la grande photo s'affiche seule.

        Afficher le bouton "Voir toutes les photos" en overlay ou en dessous.

        Optionnel : ajouter un indicateur "1/5" (non prioritaire).

    Dépendances : TASK-002-02-01.

    Fichiers concernés :

        themes/gites-theme/css/gallery.css

    Critères d'acceptation :

        Sur mobile, seule la première photo s'affiche.

        Le bouton "Voir toutes les photos" est visible.

        La navigation n'est pas affectée.

TASK-002-02-03

    Titre : Adapter la grille d'aperçu pour les tablettes

    Objectif : Gérer le rendu sur tablette (largeur 768px - 1024px).

    Description détaillée :

        Ajouter un media query pour tablettes.

        Réduire les proportions si nécessaire (ex. hauteur de 300px).

        Conserver la grille 2 colonnes ou passer à 1 colonne selon pertinence.

    Dépendances : TASK-002-02-02.

    Fichiers concernés :

        themes/gites-theme/css/gallery.css

    Critères d'acceptation :

        Le rendu tablette est cohérent avec les maquettes ou les attentes visuelles.

        Les photos restent lisibles.

TASK-002-03-01

    Titre : Rendre le clic universel sur les 5 photos

    Objectif : Toute la grille (grande photo + 4 vignettes) doit rediriger vers la page "Toutes les photos" (section 1).

    Description détaillée :

        Vérifier que chaque photo est entourée d'une balise <a> pointant vers /gites/nom-du-gite/photos.

        Si le bouton "Voir toutes les photos" est un lien distinct, le synchroniser avec la même URL.

        Aucun JS nécessaire (tout est en HTML).

    Dépendances : TASK-002-01-01.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

    Critères d'acceptation :

        Tous les clics sur la galerie mènent à la page photos.

        Le comportement est identique sur tous les gîtes.

TASK-002-04-01

    Titre : Intégrer le partial dans le template de la fiche gîte

    Objectif : Placer la galerie d'aperçu en haut de la fiche gîte (section 2.1).

    Description détaillée :

        Modifier le template principal de la fiche gîte (gite.html.twig ou équivalent).

        Inclure le partial galerie-apercu.html.twig juste après l'en-tête de page (ou au début du contenu).

        Passer la variable page au partial.

        S'assurer que l'intégration n'affecte pas le reste de la fiche.

    Dépendances : TASK-002-01-02, TASK-002-03-01.

    Fichiers concernés :

        themes/gites-theme/templates/gite.html.twig

    Critères d'acceptation :

        La galerie apparaît en haut de la fiche gîte.

        Le reste de la fiche est inchangé.

        La navigation entre fiche et page photos est opérationnelle.

Feature 3 — Page "Toutes les photos"
TASK-003-01-01

    Titre : Créer le template Twig de la page "Toutes les photos"

    Objectif : Créer gite-photos.html.twig avec la structure de base (en-tête + sections).

    Description détaillée :

        Créer themes/gites-theme/templates/gite-photos.html.twig.

        Y définir une structure : en-tête (flèche de retour + nom du gîte), puis une suite de sections par espace.

        Chaque section contient un titre (ex. "Salon") et une grille d'images.

        Ne pas implémenter le regroupement ou les images à ce stade.

    Dépendances : TASK-001-02-01.

    Fichiers concernés :

        themes/gites-theme/templates/gite-photos.html.twig

    Critères d'acceptation :

        Le template existe et est accessible via une route (même si elle n'est pas configurée).

        La structure en sections est présente.

TASK-003-01-02

    Titre : Configurer le routing Grav pour la page "Toutes les photos"

    Objectif : Associer le template à une route accessible par gîte (section 2.3).

    Description détaillée :

        Déterminer le mode de routing (sous-page physique ou route générée).

        Si sous-page : créer une page photos dans chaque gîte avec template gite-photos.

        Si route générée : configurer une route dans user/config/routes.yaml ou via un plugin.

        Option recommandée : sous-page statique pour cohérence Grav.

    Dépendances : TASK-003-01-01.

    Fichiers concernés :

        user/config/routes.yaml (si route générée)

        user/pages/01.gites/gite-la-grange/photos/ (si sous-page)

        user/pages/01.gites/*/photos/ (création par script ou manuelle)

    Critères d'acceptation :

        L'URL /gites/nom-du-gite/photos est accessible.

        Le template gite-photos est bien chargé.

        Le lien depuis la fiche fonctionne.

TASK-003-02-01

    Titre : Implémenter le regroupement des photos par catégorie dans le template

    Objectif : Afficher les photos groupées par section selon la taxonomie (section 3.4).

    Description détaillée :

        Dans gite-photos.html.twig, récupérer le frontmatter du gîte.

        Filtrer les photos par catégorie.

        Pour chaque catégorie présente, créer une section avec son titre.

        Utiliser la liste centralisée de catégories pour l'ordre d'affichage.

        Ignorer les catégories vides.

    Dépendances : TASK-003-01-01, TASK-001-01-01.

    Fichiers concernés :

        themes/gites-theme/templates/gite-photos.html.twig

    Critères d'acceptation :

        Les photos sont correctement groupées par espace.

        L'ordre des sections respecte celui du fichier de configuration.

        Les sections vides ne sont pas affichées.

TASK-003-02-02

    Titre : Créer le partial "section de photos" (réutilisable)

    Objectif : Externaliser le rendu d'une section dans un partial dédié.

    Description détaillée :

        Créer themes/gites-theme/templates/partials/galerie-section.html.twig.

        Ce partial reçoit une catégorie et une liste de photos.

        Affiche le titre de la catégorie et les photos en grille.

        Préparer la structure pour le responsive (grille CSS, cf. Feature 7).

    Dépendances : TASK-003-02-01.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-section.html.twig

    Critères d'acceptation :

        Le partial existe et peut être appelé depuis le template principal.

        Le rendu est autonome (pas de logique métier dans le partial).

TASK-003-03-01

    Titre : Mettre en place la grille responsive pour les sections (desktop)

    Objectif : Afficher 3-4 colonnes sur desktop (section 2.4).

    Description détaillée :

        Ajouter les styles CSS pour la grille desktop dans gallery.css.

        Utiliser grid-template-columns: repeat(4, 1fr) ou auto-fill avec minmax.

        Appliquer un ratio cohérent (aspect-ratio: 4/3 ou object-fit: cover).

    Dépendances : TASK-003-02-02.

    Fichiers concernés :

        themes/gites-theme/css/gallery.css

    Critères d'acceptation :

        Sur desktop, les photos s'affichent en 4 colonnes.

        Le rendu est propre et aligné.

TASK-003-03-02

    Titre : Adapter les grilles des sections pour tablette et mobile

    Objectif : Rendre les grilles de sections responsive (section 2.4).

    Description détaillée :

        Tablette (≤ 1024px) : passer à 2 colonnes.

        Mobile (≤ 768px) : passer à 1 ou 2 colonnes selon le nombre de photos.

        Assurer l'empilement vertical des sections.

    Dépendances : TASK-003-03-01.

    Fichiers concernés :

        themes/gites-theme/css/gallery.css

    Critères d'acceptation :

        Les grilles s'adaptent correctement aux différentes tailles d'écran.

        L'empilement des sections est fluide.

TASK-003-04-01

    Titre : Ajouter le bouton de retour vers la fiche

    Objectif : Implémenter la flèche de retour explicite (section 2.3).

    Description détaillée :

        Ajouter dans l'en-tête de gite-photos.html.twig un lien de retour vers la fiche du gîte.

        Utiliser un libellé clair (ex. "Retour à la fiche du gîte").

        Optionnel : ajouter une icône flèche avec aria-label.

        Le lien doit être un <a href="{{ page.parent.url }}"> pour éviter la dépendance JS.

    Dépendances : TASK-003-01-02.

    Fichiers concernés :

        themes/gites-theme/templates/gite-photos.html.twig

    Critères d'acceptation :

        Le bouton de retour est visible en haut de page.

        Le libellé est accessible.

        Le retour fonctionne sans JS.

TASK-003-04-02

    Titre : (Optionnel) Ajouter le retour à la position de scroll via JS

    Objectif : Restituer la position de scroll au retour (section 2.4).

    Description détaillée :

        Utiliser history.back() pour revenir à la page précédente avec son scroll.

        Ajouter un petit script non bloquant dans la page.

        Ce script doit être facultatif (le lien simple reste fonctionnel).

    Dépendances : TASK-003-04-01.

    Fichiers concernés :

        themes/gites-theme/templates/gite-photos.html.twig

        themes/gites-theme/js/gallery.js (à créer)

    Critères d'acceptation :

        Le retour avec JS préserve la position de scroll.

        Le retour sans JS (si JS désactivé) reste fonctionnel.

Feature 4 — Intégration Grav (templates & composants)
TASK-004-01-01

    Titre : Vérifier et valider la cohérence des variables passées aux partials

    Objectif : S'assurer que les données circulent correctement entre templates et partials.

    Description détaillée :

        Revoir les appels aux partials dans la fiche et la page photos.

        Vérifier que page, page.media, page.frontmatter sont bien accessibles.

        Ajouter des commentaires Twig pour clarifier les variables attendues par chaque partial.

    Dépendances : TASK-002-04-01, TASK-003-02-02.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

        themes/gites-theme/templates/partials/galerie-section.html.twig

        themes/gites-theme/templates/gite-photos.html.twig

        themes/gites-theme/templates/gite.html.twig

    Critères d'acceptation :

        Les données sont bien disponibles dans chaque partial.

        Aucune erreur Twig ne survient.

        La documentation des variables est ajoutée.

TASK-004-02-01

    Titre : Vérifier l'intégration avec le thème existant (override de templates)

    Objectif : S'assurer que les nouveaux templates surchargent correctement ceux du thème parent (si applicable).

    Description détaillée :

        Vérifier le système de thème Grav utilisé (parent/child).

        S'assurer que gite-photos.html.twig est bien dans le bon répertoire pour être utilisé.

        Tester l'affichage sur un environnement de développement.

    Dépendances : TASK-003-01-01, TASK-002-04-01.

    Fichiers concernés :

        themes/gites-theme/templates/

    Critères d'acceptation :

        Les templates sont bien pris en compte par Grav.

        Aucun conflit avec les templates existants.

Feature 5 — Performance & optimisation des images
TASK-005-01-01

    Titre : Configurer la génération d'images responsive dans Grav

    Objectif : Utiliser le moteur de médias Grav pour générer des images en WebP et multiples tailles (section 5).

    Description détaillée :

        Configurer les tailles d'image par défaut dans user/config/media.yaml.

        Définir des tailles pour la grande photo (ex. 800w, 1200w), les vignettes (400w, 600w), et les pages photos (600w, 900w).

        Activer la conversion WebP si possible.

        Ajouter les attributs srcset et sizes dans les templates.

    Dépendances : TASK-004-01-01.

    Fichiers concernés :

        user/config/media.yaml

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

        themes/gites-theme/templates/partials/galerie-section.html.twig

    Critères d'acceptation :

        Les images sont servies en WebP (avec fallback JPEG).

        Plusieurs résolutions sont disponibles (srcset).

        La bonne taille est chargée selon l'écran.

TASK-005-02-01

    Titre : Appliquer le lazy loading et la priorisation des images

    Objectif : Optimiser le chargement (LCP, CLS) (section 5).

    Description détaillée :

        Ajouter loading="lazy" sur toutes les images sauf la grande photo de la fiche.

        Ajouter fetchpriority="high" sur la grande photo de la fiche.

        Vérifier que le LCP est bien la grande photo.

    Dépendances : TASK-005-01-01.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

        themes/gites-theme/templates/partials/galerie-section.html.twig

    Critères d'acceptation :

        Les images hors écran ne se chargent pas immédiatement.

        La grande photo est chargée en priorité.

        Le LCP est optimisé.

TASK-005-03-01

    Titre : Ajouter les attributs width/height et ratios pour prévenir le CLS

    Objectif : Stabiliser la mise en page (section 5).

    Description détaillée :

        Ajouter les attributs width et height sur chaque balise <img>.

        Utiliser aspect-ratio en CSS pour maintenir les proportions.

        Vérifier qu'aucun décalage de mise en page n'a lieu.

    Dépendances : TASK-005-02-01.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

        themes/gites-theme/templates/partials/galerie-section.html.twig

        themes/gites-theme/css/gallery.css

    Critères d'acceptation :

        Aucun CLS détecté lors du chargement.

        Les dimensions sont explicites pour chaque image.

Feature 6 — Accessibilité
TASK-006-01-01

    Titre : Ajouter les textes alternatifs (alt) obligatoires

    Objectif : Rendre chaque image accessible (section 6).

    Description détaillée :

        Vérifier que le champ alt est présent dans le frontmatter pour chaque photo.

        Utiliser image.alt dans les templates Twig pour renseigner l'attribut alt.

        Ajouter un fallback si alt est manquant (ex. "Photo du gîte").

    Dépendances : TASK-005-03-01, TASK-001-02-01.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

        themes/gites-theme/templates/partials/galerie-section.html.twig

    Critères d'acceptation :

        Chaque image possède un attribut alt renseigné.

        Les valeurs proviennent des données frontmatter.

TASK-006-01-02

    Titre : Assurer une structure de titres cohérente (h1, h2…)

    Objectif : Respecter la hiérarchie sémantique (section 6).

    Description détaillée :

        Dans gite-photos.html.twig, utiliser <h1> pour le titre du gîte ou de la page.

        Utiliser <h2> pour chaque section d'espace (Salon, Cuisine, etc.).

        Vérifier que les titres sont présents et bien ordonnés.

    Dépendances : TASK-003-02-02.

    Fichiers concernés :

        themes/gites-theme/templates/gite-photos.html.twig

        themes/gites-theme/templates/partials/galerie-section.html.twig

    Critères d'acceptation :

        La hiérarchie des titres est valide (h1 puis h2).

        Un lecteur d'écran peut naviguer par sections.

TASK-006-02-01

    Titre : Assurer la navigation clavier sur tous les éléments cliquables

    Objectif : Les liens doivent être focusables et actionnables au clavier (section 6).

    Description détaillée :

        Vérifier que tous les éléments cliquables sont des balises <a> (ou <button> avec role="link").

        Tester la navigation au clavier (Tab, Entrée).

        S'assurer que le focus est visible (style :focus-visible).

    Dépendances : TASK-002-03-01, TASK-003-04-01.

    Fichiers concernés :

        themes/gites-theme/templates/partials/galerie-apercu.html.twig

        themes/gites-theme/templates/gite-photos.html.twig

        themes/gites-theme/css/gallery.css

    Critères d'acceptation :

        Tous les liens sont navigables au clavier.

        Le focus est clairement visible.

        Aucun élément <div> cliquable sans gestionnaire ARIA.

TASK-006-03-01

    Titre : Garantir le contraste du bouton "Voir toutes les photos"

    Objectif : Assurer la lisibilité du texte superposé (section 6).

    Description détaillée :

        Ajouter un fond semi-transparent derrière le texte du bouton.

        Vérifier un contraste d'au moins 4.5:1.

        Tester sur différentes photos (claires/sombres).

    Dépendances : TASK-002-01-01.

    Fichiers concernés :

        themes/gites-theme/css/gallery.css

    Critères d'acceptation :

        Le texte est lisible sur tous les types de photos.

        Le rapport de contraste est vérifié.

Feature 7 — Habillage visuel (CSS)
TASK-007-01-01

    Titre : Harmoniser les styles de la galerie avec la charte graphique

    Objectif : Utiliser les variables CSS existantes (couleurs, polices, ombres) (section 4.3).

    Description détaillée :

        Inspecter le thème existant pour récupérer les variables de couleur, de rayon de bordure, d'ombres.

        Appliquer ces variables dans gallery.css au lieu de valeurs en dur.

        Vérifier la cohérence visuelle avec le reste du site.

    Dépendances : TASK-002-02-01, TASK-003-03-01.

    Fichiers concernés :

        themes/gites-theme/css/gallery.css

        themes/gites-theme/css/variables.css (si existant)

    Critères d'acceptation :

        Les couleurs et styles sont cohérents avec le site.

        Aucune valeur en dur non justifiée.

TASK-007-01-02

    Titre : Finaliser le style des boutons (retour, voir toutes les photos)

    Objectif : Appliquer les styles finaux aux boutons (section 2.3, 2.1).

    Description détaillée :

        Styliser le bouton "Voir toutes les photos" avec hover, focus, active.

        Styliser la flèche de retour (icône + texte).

        Assurer une cohérence avec les autres boutons du thème.

    Dépendances : TASK-002-02-02, TASK-003-04-01.

    Fichiers concernés :

        themes/gites-theme/css/gallery.css

    Critères d'acceptation :

        Les boutons sont conformes au design système.

        Les états interactifs sont corrects.

TASK-007-01-03

    Titre : Vérifier le rendu global sur les principaux navigateurs

    Objectif : Assurer la compatibilité (Chrome, Firefox, Safari, Edge).

    Description détaillée :

        Tester les pages sur les navigateurs cibles.

        Vérifier les grilles CSS, les recadrages, et les interactions.

        Corriger les éventuelles divergences.

    Dépendances : Toutes les tâches CSS antérieures.

    Fichiers concernés :

        Ajustements dans gallery.css si nécessaire.

    Critères d'acceptation :

        Le rendu est identique ou acceptable sur les 4 navigateurs.

        Aucune régression fonctionnelle.

Récapitulatif des dépendances (ordre recommandé)

    TASK-000-01-01 → TASK-000-01-02

    TASK-001-01-01 → TASK-001-02-01 → TASK-001-02-02 → TASK-001-03-01

    TASK-002-01-01 → TASK-002-01-02 → TASK-002-01-03

        En parallèle : TASK-002-03-01 (peut être fait après 001-01)

        Puis TASK-002-04-01

    CSS associé : TASK-002-02-01, 002-02-02, 002-02-03 (peut être fait en parallèle après les partials)

    TASK-003-01-01 → TASK-003-01-02 → TASK-003-02-01 → TASK-003-02-02 → TASK-003-03-01 → 003-03-02 → 003-04-01 → 003-04-02

    TASK-004-01-01 → TASK-004-02-01 (peut être fait en fin de parcours)

    TASK-005-01-01 → 005-02-01 → 005-03-01

    TASK-006-01-01 → 006-01-02 → 006-02-01 → 006-03-01 (peut être fait en parallèle avec les tâches correspondantes)

    TASK-007-01-01 → 007-01-02 → 007-01-03 (finalisation)
