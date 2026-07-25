# Conventions Git

## Objectif

Garantir que l'historique Git reste lisible, traçable, et directement corrélé au plan de développement (`docs/planning/deepseek-plan-normalized.md`) et au suivi des Tasks (`docs/planning/task-status.md`).

## Règles

### Granularité des commits

- Un commit correspond, dans la mesure du possible, à une seule Task validée par l'humain.
- Une préparation technique hors plan (ex. cette préparation de dépôt) peut faire l'objet d'un commit séparé, explicitement identifié comme tel.
- Aucun commit ne doit mélanger du code applicatif et une modification d'infrastructure.

### Message de commit

Format recommandé :

```
<identifiant Task ou nature du changement> — <résumé court>

<corps optionnel : contexte, justification>
```

Exemples :
```
TASK-002-01-01 — Identifier les champs nécessaires d'une fiche de gîte
```
```
Préparation dépôt — .gitignore, squelette thème, conventions de base
```

### Ce qui ne doit jamais être commité

Voir `.gitignore` à la racine : secrets runtime (`security-private.php`, `api-private.php`), comptes utilisateurs (`grav/user/accounts/`), données d'exécution (`cache/`, `logs/`, `backup/`, `images/`, `data/`), plugins et thème officiels Grav (vendor).

### Quand commiter

- Jamais automatiquement : un commit n'est créé que sur demande humaine explicite, conformément à `CLAUDE.md` et `docs/workflow/12-developpement-claude.md`.
- Un commit est proposé (message suggéré) en fin de Task, après validation du compte rendu de livraison, mais n'est exécuté qu'après accord explicite.

### Branches

Aucune stratégie de branches n'est définie à ce jour (le dépôt travaille sur `main`). Cette convention sera complétée si une stratégie de branches devient nécessaire — elle n'est pas anticipée ici.

## Moment d'utilisation

À chaque fin de Task, avant de proposer un message de commit, et à chaque fois qu'une modification est sur le point d'être intégrée au dépôt.
