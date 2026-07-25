# Plan recalé — Nouvelle présentation photographique des gîtes

Ce document recale le plan produit par DeepSeek (`docs/planning/deepseek-plan-gallerie.md`) sur l'état réel du dépôt et sur l'architecture validée (`docs/workflow/etude-architecture-galerie-photos-gites.md`), conformément aux décisions actées avec l'utilisateur (2026-07-20).

Le plan DeepSeek reste la référence d'inventaire initial ; ce document est la référence d'exécution. En cas de divergence, ce document prévaut pour le séquencement, DeepSeek reste consultable pour le détail narratif de chaque Task d'origine.

## Décisions actées avant recalage

1. **Administration** : une Task est ajoutée (TASK-GAL-01-03) pour exposer les métadonnées de galerie via un blueprint Grav, dans le cadre des mécanismes d'accès déjà établis — aucun nouveau rôle, aucune nouvelle politique d'autorisation, aucune page de gestion autonome.
2. **Métadonnées photo** : Option A conservée (liste centralisée dans le frontmatter du gîte), texte alternatif inclus dans cette même structure. Le mécanisme natif `<image>.meta.yaml` de Grav est écarté pour cette implémentation (évite une double source de vérité) — sera mentionné en documentation comme alternative étudiée, non retenue.
3. **Page « Toutes les photos »** : sous-page physique Grav (pas de route virtuelle, pas de plugin de routage), exploitant les données du gîte parent sans duplication.
4. **JavaScript** : aucun, sauf nécessité technique démontrée en cours de Task. Lien de retour déterministe (`<a href="...">` vers la fiche), jamais `history.back()`.
5. **Contenu de démonstration** : les 2 gîtes réels n'ont que 2 photos chacun — non bloquant, sert à valider les cas de repli (0, 1-4, 5, >5 photos).

## Table de correspondance

| ID(s) DeepSeek | Statut | ID recalé | Résumé de l'adaptation |
|---|---|---|---|
| TASK-000-01-01 | Conservée, adaptée | **TASK-GAL-00-01** ✅ | Cible réelle : `docs/model/gite.md` (section existante à étendre, pas de nouveau fichier). Inclut également le contenu de TASK-001-02-02 (règle de repli photo non catégorisée) et TASK-001-03-01 (règle moins de 5 photos), qui sont de la documentation, pas des Tasks de code séparées. |
| TASK-000-01-02 | Conservée, adaptée | **TASK-GAL-00-02** ✅ | Cible réelle : `docs/conventions/twig.md` uniquement (nommage des partials, grilles CSS, images responsives/lazy loading) — pas `docs/conventions/yaml.md` (portée sur la syntaxe YAML générale, sans lien avec le rendu d'images ; le schéma `galerie.photos` vit dans `docs/model/gite.md`), ni un nouveau `conventions-theme.md`. Correction faite en exécutant la Task. |
| TASK-001-01-01 | Conservée, adaptée | **TASK-GAL-01-01** ✅ | Taxonomie créée dans `grav/user/config/gites-photos-taxonomie.yaml` (accessible via `grav.config.get(...)`, vérifié en rendu HTTP réel — pas une constante Twig, car aussi requise par le blueprint TASK-GAL-01-03, non Twig). |
| TASK-001-02-01 | Conservée, portée élargie | **TASK-GAL-01-02** ✅ | Traite les **deux** gîtes réels (`gite-un` et `gite-deux`). Portée étendue sur demande utilisateur : 3 photos placeholder supplémentaires générées par gîte (style visuel identique aux 2 existantes, texte « PHOTO A VENIR » honnête, aucun contenu réel inventé) pour porter chaque gîte à 5 photos et couvrir plusieurs catégories dès les tests suivants. `galerie.photos` renseigné pour les 5 photos de chaque gîte, vérifié en lecture réelle (`page.header`). |
| TASK-001-02-02, TASK-001-03-01 | Fusionnées | *(dans TASK-GAL-00-01)* | Règles de repli documentées avec le reste du modèle de données, pas en Tasks séparées. |
| — | **Ajoutée** | **TASK-GAL-01-03** ✅ | Blueprint `grav/user/themes/gites-theme/blueprints/gite-item.yaml` créé, `extends@: default` (hérite de `quark2/blueprints/default.yaml`, mécanisme vérifié fonctionnel — distinct de l'`extends@` de niveau thème, resté inopérant). Onglet « Galerie photographique » ajouté, exposant uniquement `galerie.photos` (liste : fichier/alt/espace/ordre/vitrine) — aucun autre champ touché. Vérifié via l'API admin2 réelle : blueprint résolu (`GET /blueprints/pages/gite-item`), modification réelle testée et persistée puis restaurée, champs existants (`equipements`, `coordonnees`) intacts. Aucun nouveau rôle, aucune nouvelle politique d'autorisation. |
| TASK-002-01-01, TASK-002-03-01 | Fusionnées | **TASK-GAL-02-01** ✅ | `galerie-apercu.html.twig` créé et intégré dans `gite-item.html.twig` (après le contenu, avant l'ancienne galerie plate). Sélection simple par tri sur `vitrine` (repli complet réservé à TASK-GAL-02-02/03). Overlay « Voir toutes les photos » sur la dernière vignette (pas un élément séparé), conforme à l'architecture. Testé en HTTP réel sur les deux gîtes : 5 liens vers `/gites/<slug>/photos` (404 attendu, page pas encore créée), images redimensionnées accessibles (200), ordre `vitrine` respecté, non-régression complète. |
| TASK-002-01-02 | Conservée | **TASK-GAL-02-02** ✅ | Repli implémenté : si moins de 5 photos marquées `vitrine`, complétées automatiquement par les premières photos non retenues (ordre de déclaration). **Vérifié empiriquement** (pas seulement lu) : `vitrine` retiré temporairement de 3 des 5 photos de `gite-un` → les 5 photos s'affichent quand même, dans l'ordre attendu (2 explicites + 3 complétées) ; données restaurées et revérifiées après test, non-régression complète. |
| TASK-002-01-03 | Conservée, portée élargie | **TASK-GAL-02-03** ✅ | Comportements de repli complets vérifiés empiriquement (0, 1, 3, >5 photos, sur `gite-un`, données restaurées après chaque test). **Défaut réel trouvé et corrigé** : avec exactement 1 photo, le lien « Voir toutes les photos » disparaissait entièrement (rattaché uniquement à la dernière vignette, inexistante dans ce cas) — corrigé en le plaçant en overlay sur la grande photo quand aucune vignette n'existe. Plafonnement à 5 confirmé structurellement (doublon de test). |
| TASK-002-02-01, TASK-002-02-03 | Fusionnées | **TASK-GAL-02-04** ✅ | CSS ajouté à `custom.css` : grille 2 colonnes desktop, `object-fit: cover`, coins arrondis (`var(--q2-radius)`, réutilisation anticipée), hauteur réduite sous 860px (tablette). Aucune largeur fixe en px (fluidité confirmée). Non-régression complète. |
| TASK-002-02-02 | Conservée | **TASK-GAL-02-05** ✅ | CSS mobile ajouté (sous 720px : vignettes masquées, grande photo seule en 260px). **Problème anticipé et corrigé avant régression** : le lien « Voir toutes les photos » aurait disparu sur mobile dès qu'il y a plusieurs photos (rattaché à la dernière vignette, masquée) — un second overlay (`--mobile`, masqué par défaut, affiché sous 720px) a été ajouté sur la grande photo. Indicateur « 1/5 » écarté (explicitement facultatif dans l'architecture et le plan DeepSeek). Overlay desktop toujours actif au-dessus de 720px, non-régression complète. |
| TASK-002-04-01 | Conservée, chemin corrigé | **TASK-GAL-02-06** ✅ | Partial déjà inclus depuis TASK-GAL-02-01 ; cette Task a retiré l'ancienne section `gite-gallery` (grille plate `page.media().images()`), devenue redondante avec la nouvelle grille d'aperçu. Une seule présentation photographique désormais sur la fiche, reste de la fiche intact, non-régression complète. |
| TASK-003-01-01, TASK-003-01-02 | Fusionnées | **TASK-GAL-03-01** ✅ | Sous-pages physiques créées (`03.gites/01.gite-un/01.photos/`, `02.gite-deux/01.photos/`) et `gite-photos.html.twig` (en-tête, lien de retour via `page.parent`, sans duplication de données). Testé en HTTP réel : `/gites/gite-un/photos` et `/gites/gite-deux/photos` → 200, titre et lien de retour corrects pour chaque gîte, le lien déjà posé depuis la fiche (TASK-GAL-02-01) mène désormais à une vraie page (200, plus 404). |
| TASK-003-02-01, TASK-003-02-02 | Fusionnées | **TASK-GAL-03-02** ✅ | Regroupement par catégorie implémenté (`gite-photos.html.twig`, boucle sur la taxonomie) + partial `galerie-section.html.twig` (sans logique métier). Testé en HTTP réel sur les deux gîtes : 5 sections chacun, ordre de la taxonomie respecté, catégorie vide correctement absente (« Extérieurs » pour `gite-un`, « Photos supplémentaires » pour `gite-deux`), images et libellés corrects. |
| TASK-003-03-01, TASK-003-03-02 | Fusionnées | **TASK-GAL-03-03** ✅ | Grille fluide `auto-fill`/`minmax(220px, 1fr)` (architecture §4.3, évite les media queries multiples), `aspect-ratio: 4/3` + `object-fit: cover` pour un recadrage homogène. Aucun nombre de colonnes fixe codé en dur (vérifié). Testé en HTTP réel, non-régression complète. |
| TASK-003-04-01 | Conservée | **TASK-GAL-03-04** ✅ | Satisfaite par l'existant, sans nouvelle action technique — le lien de retour (déterministe, sans JS, libellé clair, focusable au clavier) est déjà en place depuis TASK-GAL-03-01. |
| TASK-003-04-02 | **Écartée** | — | `history.back()` explicitement exclu par la décision utilisateur (section 6). |
| TASK-004-01-01, TASK-004-02-01 | **Écartées** | — | TASK-004-01-01 : test de cohérence des variables, intégré aux critères d'acceptation de chaque Task concernée plutôt qu'une Task de vérification autonome (pratique déjà appliquée dans ce projet, ex. TASK-007-03-01). TASK-004-02-01 : **déjà satisfaite** — mécanisme d'héritage de thème (`streams.schemes.theme.paths`) déjà vérifié et documenté (TASK-002-02-01 historique). |
| TASK-005-01-01 | Conservée | **TASK-GAL-05-01** ✅ | `srcset`/`sizes` implémentés sur les 3 points d'affichage (grande, vignettes, sections), via `ImageMedium::derivatives()`/`.srcset()`/`.sizes()` (API vérifiée dans le code source). **WebP explicitement écarté** : `.format('webp')` existe mais GD ne supporte pas `imagewebp()` dans cet environnement (vérifié) — nécessiterait une modification de l'image Docker, hors périmètre. **Bug réel trouvé et corrigé** : `.url()` réinitialise les alternatives par défaut (`$reset=true`), vidant le `srcset` généré juste après si appelé sans argument — corrigé via `.url(false)`. Toutes les URLs générées (15 variantes) vérifiées accessibles en HTTP réel, non-régression complète. |
| TASK-005-02-01 | Conservée | **TASK-GAL-05-02** ✅ | `fetchpriority="high"` sur la grande photo (sans `loading="lazy"`), `loading="lazy"` sur les 4 vignettes et sur toutes les images de la page « Toutes les photos ». Vérifié en HTTP réel sur les 3 points d'affichage, non-régression complète. |
| TASK-005-03-01 | Fusionnée | *(dans TASK-GAL-05-01/02)* | Dimensions explicites/CLS vérifiées comme critère d'acceptation de ces deux Tasks, pas une Task distincte — à confirmer si déjà couvert nativement par le moteur d'image Grav en Phase A. |
| TASK-006-01-01 | Conservée | **TASK-GAL-06-01** ✅ | Repli défensif ajouté (`|default('Photographie du gîte')`) sur les 3 points d'affichage, complétant le comportement déjà documenté dans `docs/model/gite.md`. **Vérifié empiriquement** : `alt` retiré temporairement d'une photo de `gite-un` → repli affiché correctement ; données restaurées et revérifiées. |
| TASK-006-01-02 | Fusionnée | *(dans TASK-GAL-03-01)* | Hiérarchie des titres = propriété native de la structure du template à sa création, pas une Task séparée. |
| TASK-006-02-01 | **Écartée en tant que Task séparée** | — | Navigation clavier vérifiée comme critère d'acceptation transversal de chaque Task de rendu (cohérent avec le reste du projet), pas une Task de vérification autonome. |
| TASK-006-03-01, TASK-007-01-02 | Fusionnées | **TASK-GAL-06-02** ✅ | **Problème de contraste identifié avant qu'il ne devienne visible** : l'overlay initial (opacité 0,45) était insuffisant contre une photo claire (≈1,75:1, très en dessous du seuil AA 4,5:1) — les photos placeholder actuelles masquaient ce défaut. Renforcé à 0,7. États `:focus-visible` ajoutés (grande photo, vignettes, bouton retour), repris de `quark2/css/theme.css` (`--q2-focus-ring`). **Limite explicite** : pas d'outil de mesure de contraste réel disponible, valeur choisie par marge de sécurité conservative, pas une mesure WCAG certifiée. |
| TASK-007-01-01 | Conservée, cible corrigée | **TASK-GAL-07-01** ✅ | Satisfaite par l'existant — audit exhaustif confirmant que l'harmonisation (`var(--q2-radius)`, `var(--q2-focus-ring)`) était déjà faite anticipativement (TASK-GAL-02-04/03-03/06-02). Deux valeurs en dur restantes examinées et **volontairement conservées** : `color: #fff` (utiliser `var(--q2-text-inverse)` aurait cassé la lisibilité en mode sombre, cette variable s'inversant) et `rgba(0,0,0,0.7)` (aucun token de voile/overlay équivalent dans `quark2`). |
| TASK-007-01-03 | **Écartée** | — | Vérification multi-navigateurs hors de portée des outils disponibles dans cet environnement (pas de navigateur, limite déjà documentée à plusieurs reprises dans ce projet) — recommandée en vérification manuelle par l'utilisateur, pas une Task exécutable par moi. |

**Bilan** : 45 Tasks DeepSeek → **20 Tasks exécutables** (2 documentation, 3 modèle de données + blueprint, 6 galerie d'aperçu, 4 page photos, 2 performance, 2 accessibilité, 1 CSS charte), 8 Tasks écartées ou déjà satisfaites, 1 Task ajoutée.

## État final

**Les 20 Tasks du plan recalé sont toutes terminées (20/20).** La nouvelle présentation photographique (grille d'aperçu 1 grande + 4 vignettes, page « Toutes les photos » groupée par espace) est fonctionnellement complète : structure, modèle de données, administration (blueprint), CSS responsive (desktop/tablette/mobile), performance (`srcset`/`sizes`, lazy loading, priorité LCP) et accessibilité (texte alternatif, contraste, focus clavier).

Plusieurs défauts réels ont été détectés et corrigés en cours de route (non simplement supposés corrects) : lien « Voir toutes les photos » disparaissant avec 1 seule photo ou sur mobile (TASK-GAL-02-03/02-05), perte du `srcset` causée par le comportement par défaut de `ImageMedium::url()` (TASK-GAL-05-01), contraste insuffisant de l'overlay contre une photo claire (TASK-GAL-06-02).

## Correctif post-livraison (retour utilisateur, 2026-07-22)

Signalé après validation du plan : les 4 vignettes apparaissaient sous la grande photo plutôt qu'à sa droite, et le conteneur de la fiche (`article.content-item.gite-item`, limité à 960px par `quark2`) était jugé trop étroit. Corrigé dans `custom.css` :
- Élargissement scindé à `1200px`, spécifique aux fiches de gîte uniquement (`#body-wrapper > .container > .content-item.gite-item`, sélecteur de spécificité égale/supérieure à celui de `quark2` pour garantir la priorité sans `!important`) — aucune autre page affectée.
- `grid-auto-flow: column` ajouté à `.galerie-apercu` pour lever toute ambiguïté de disposition (aucune règle conflictuelle trouvée par analyse statique du CSS `quark2`, la cause exacte du rendu initial n'a pas pu être confirmée sans navigateur — cache CSS non actualisé ou largeur d'écran ≤ 720px les deux hypothèses les plus probables).
- Non-régression complète confirmée ; vérification visuelle réelle recommandée côté utilisateur (Ctrl+F5).

## Correctif post-livraison n°2 (retour utilisateur, 2026-07-22)

Demandé après confirmation du correctif n°1 : la page « Toutes les photos » (`article.content-item.gite-photos`, classe distincte de `gite-item`, donc non concernée par le premier élargissement) restait plafonnée à 960px. Corrigé :
- `#body-wrapper > .container > .content-item.gite-photos { max-width: 100%; }` — utilise toute la largeur de `.container` (jusqu'à 1200px), sans dupliquer cette valeur en dur.
- Taille minimale des vignettes de section augmentée (`minmax(220px, 1fr)` → `minmax(320px, 1fr)`) pour des photos plus grandes, profitant de l'espace gagné.
- Non-régression complète confirmée ; vérification visuelle réelle recommandée côté utilisateur.

## Correctif post-livraison n°3 (retour utilisateur, 2026-07-22)

Signalé après le correctif n°2 : photos pleine largeur sur mobile/tablette, mais restant petites sur grand écran desktop. **Cause identifiée** : nos gîtes n'ont qu'une seule photo par espace ; avec `auto-fill`, la grille réservait plusieurs colonnes vides de 320px sur un écran large (assez pour en contenir plusieurs), la photo réelle restant coincée dans une seule colonne étroite. Sur petit écran, moins de colonnes tenaient, donc la photo unique occupait déjà toute la largeur — d'où la différence de comportement observée. Corrigé en remplaçant `auto-fill` par `auto-fit` (`galerie-section-grid`) : les colonnes vides s'effondrent, la ou les photos réelles s'étirent pour occuper tout l'espace, à toute largeur d'écran. Non-régression complète confirmée ; vérification visuelle réelle recommandée côté utilisateur.

**Limites connues, non levées par ce travail** :
- Rendu visuel réel en navigateur jamais vérifié (aucun outil de capture disponible dans cet environnement) — vérification visuelle recommandée côté utilisateur.
- Conversion WebP écartée (GD sans support `imagewebp` dans ce conteneur) — nécessiterait une modification de l'image Docker.
- Contenu photographique des deux gîtes toujours composé de placeholders (« PHOTO À VENIR ») — à remplacer par de vraies photos quand disponibles.
- `gite-un` a des coordonnées GPS réelles mais reste concerné par ce point pour les photos ; aucun blocage technique, juste du contenu à fournir.

## Séquencement recommandé

```
TASK-GAL-00-01 → TASK-GAL-00-02
TASK-GAL-01-01 → TASK-GAL-01-02 → TASK-GAL-01-03
TASK-GAL-01-02 → TASK-GAL-02-01 → TASK-GAL-02-02 → TASK-GAL-02-03 → TASK-GAL-02-04 → TASK-GAL-02-05 → TASK-GAL-02-06
TASK-GAL-01-02 → TASK-GAL-03-01 → TASK-GAL-03-02 → TASK-GAL-03-03 → TASK-GAL-03-04
(TASK-GAL-02-06, TASK-GAL-03-04) → TASK-GAL-05-01 → TASK-GAL-05-02
(TASK-GAL-02-01, TASK-GAL-03-01) → TASK-GAL-06-01
(TASK-GAL-02-04, TASK-GAL-03-03) → TASK-GAL-06-02 → TASK-GAL-07-01
```

Une Task à la fois, aucune Task suivante démarrée automatiquement (CLAUDE.md).
