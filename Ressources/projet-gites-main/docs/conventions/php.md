# Conventions PHP

## Objectif

Garantir un code PHP applicatif lisible, conforme aux conventions Grav, et strictement limité à la responsabilité de chaque plugin (DT-009).

## Règles

### Style de code

- PSR-12 pour la mise en forme (indentation 4 espaces, accolades sur leur propre ligne pour les classes/méthodes).
- Typage strict des paramètres et valeurs de retour partout où c'est possible (`array`, `void`, `string`, etc.), cohérent avec les signatures déjà utilisées par l'API native de Grav (`Page::header()`, `Page::save()`).

### Espaces de noms

- `Grav\Plugin\<NomDuPlugin>\...` pour les classes propres à un plugin, conforme à la convention native des plugins Grav — même avant que le plugin ne soit formellement structuré (blueprint, classe principale).

### Organisation des classes

- Une classe = une responsabilité. Pas de classe « fourre-tout » mélangeant lecture/écriture de données, validation et rendu.
- Les fonctions d'accès aux données (lecture/écriture) restent génériques et ne contiennent pas de logique métier spécifique à une action utilisateur (ex. « ajouter une période ») — cette logique appartient à la Task/Feature qui la demande explicitement.
- Pas de dépendance externe (composer) sans validation explicite préalable (cf. `docs/workflow/12-developpement-claude.md` — gestion des dépendances techniques).

### Interaction avec l'API Grav

- Toujours vérifier l'existence réelle d'une méthode dans le code source de Grav avant de l'utiliser (leçon de l'incident `extends@`, TASK-002-02-01) plutôt que de supposer une API par analogie avec d'autres CMS.
- Utiliser les interfaces Grav (`PageInterface`) plutôt que les classes concrètes quand disponibles, pour rester compatible avec les évolutions internes de Grav.

## Moment d'utilisation

Dès la première Task de développement du plugin Calendrier (EPIC-003, déclenchée par TASK-003-01-03) et pour tout code PHP applicatif ultérieur (EPIC-005, EPIC-008, etc.).
