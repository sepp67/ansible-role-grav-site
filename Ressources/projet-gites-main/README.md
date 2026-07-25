# Projet gîtes — Plateforme de location saisonnière

Plateforme de mise en relation directe entre propriétaires de gîtes et vacanciers (Alsace & Vosges), sans commission ni gestion de paiement. Voir [`docs/context/project-context.md`](docs/context/project-context.md) pour la vision complète du produit.

## Démarrage local

```bash
docker compose build
docker compose up -d
```

- Site : [http://localhost:8080](http://localhost:8080)
- Admin : [http://localhost:8080/admin](http://localhost:8080/admin)

Le contenu Grav (`grav/user/`) est monté directement dans le conteneur (bind mount) : toute modification d'un fichier sous `grav/user/` est immédiatement visible sans reconstruire l'image ni redémarrer le conteneur.

```bash
docker compose logs -f      # voir les logs
docker compose down         # arrêter
```

## Structure du dépôt

```
projet-gites/
├── docs/                 # documentation du projet (contexte, décisions, plan, conventions)
├── grav/user/            # contenu Grav applicatif (pages, thème, plugins, configuration)
├── docker/, Dockerfile, docker-compose.yml   # environnement de développement local
```

Dans `grav/user/` :
- `themes/gites-theme/` — thème du projet, hérite du thème officiel `quark2`.
- `plugins/` — plugins officiels Grav (vendor, non modifiés directement) ; un futur plugin métier (calendrier de disponibilités) sera ajouté au fil du plan de développement.
- `pages/` — contenu éditorial (gîtes, pages du site).
- `config/` — configuration applicative du site.

`themes/quark2/` et les plugins officiels sont vendorisés (téléchargés par le `Dockerfile`) et ne doivent jamais être modifiés directement — voir [`docs/conventions/git.md`](docs/conventions/git.md) et les autres conventions dans `docs/conventions/`.

## Workflow de développement

Ce dépôt suit une méthode de développement incrémentale, une Task à la fois, décrite dans [`CLAUDE.md`](CLAUDE.md) et [`docs/workflow/12-developpement-claude.md`](docs/workflow/12-developpement-claude.md).

Avant de commencer toute Task :
1. lire [`docs/context/project-context.md`](docs/context/project-context.md), [`docs/context/constraints.md`](docs/context/constraints.md), [`docs/context/terminology.md`](docs/context/terminology.md) ;
2. lire les Decision Records applicables dans [`docs/dr/`](docs/dr/) ;
3. identifier la Task dans [`docs/planning/deepseek-plan-normalized.md`](docs/planning/deepseek-plan-normalized.md) ;
4. consulter l'état courant dans [`docs/planning/task-status.md`](docs/planning/task-status.md) ;
5. suivre les conventions applicables dans [`docs/conventions/`](docs/conventions/).

## Conventions de développement

Voir [`docs/conventions/`](docs/conventions/) : conventions Git, Twig, YAML (d'autres conventions — CSS, PHP, JavaScript, nommage — seront ajoutées au fil du développement, lorsqu'elles deviendront nécessaires).
