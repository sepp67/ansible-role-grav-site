# Conventions YAML

## Objectif

Garantir une structure homogène des métadonnées de pages, de la configuration et des blueprints, afin que les Tasks successives produisent des fichiers YAML cohérents entre eux et faciles à relire.

## Règles

### Format

- Indentation : 2 espaces, jamais de tabulation, pour tout fichier YAML **rédigé à la main** (cohérent avec tous les fichiers YAML déjà présents dans `grav/user/config/` et dans `quark2`).
- Pas de guillemets inutiles ; guillemets simples réservés aux valeurs contenant des caractères spéciaux (`:`, accents en tête de valeur, etc.), à l'image de `email: 'joe@example.com'` déjà utilisé dans `grav/user/config/site.yaml`.
- Listes en notation `- élément`, pas en notation inline `[a, b, c]`, sauf pour des listes très courtes de valeurs techniques.
- **Exception constatée (TASK-003-01-03)** : tout fichier de page modifié programmatiquement via `Page::header()` + `Page::save()` (API native Grav) est **entièrement re-sérialisé par Grav** selon son propre style (indentation 4 espaces, guillemets simples systématiques, listes vides en `{}`). Ce n'est pas une erreur ni une non-conformité à corriger à la main : Grav réécrit le fichier à chaque sauvegarde programmatique, donc un reformatage manuel ne serait jamais durable. La règle des 2 espaces reste la référence uniquement pour les fichiers créés/édités directement par une Task (sans passer par `Page::save()`).

### Nommage des clés

- **Clés techniques imposées par Grav** (`title`, `body_classes`, `theme`, `enabled`, etc.) : restent en anglais, telles que définies par Grav — elles ne sont pas traduites.
- **Champs métier propres au projet** (attributs d'un gîte : capacité, équipements, période de disponibilité, etc.) : nommés en français, avec le vocabulaire exact de `docs/context/terminology.md`, en `snake_case` (ex. `nombre_chambres`, `capacite_max`, `equipements`).
- Ne jamais mélanger les deux conventions dans une même clé.

### Dates

- Format ISO 8601 (`AAAA-MM-JJ`), cohérent avec l'usage YAML standard et avec Grav.

### Blueprints

- Suivre la structure déjà utilisée par les blueprints Grav natifs (`grav/user/themes/quark2/blueprints.yaml`, `grav/user/plugins/*/blueprints.yaml`) : `name`, `version`, `description`, `author`, puis la section `form:` pour les champs éditables.
- Un blueprint ne définit que les champs réellement nécessaires à la Task en cours ; ne pas anticiper des champs non encore requis.

### Secrets et données sensibles

- Aucune valeur secrète (mot de passe, jeton, clé API) n'est écrite en clair dans un fichier YAML versionné. Les fichiers `*-private.php` restent la seule source de secrets runtime et sont exclus du dépôt (`.gitignore`).

## Moment d'utilisation

Dès la première Task définissant une structure de métadonnées (TASK-002-01-02 — définition de la structure YAML des gîtes), et pour toute création ou modification de fichier YAML par la suite (configuration, blueprint, page).
