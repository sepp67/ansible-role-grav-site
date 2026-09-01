# Changelog

Toutes les évolutions notables de ce rôle sont consignées ici.

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).
Versionnement : [SemVer](https://semver.org/lang/fr/). Les versions correspondent aux
tags Git du dépôt.

## [Non publié] — préparation de `2.0.0`

Refonte du rôle selon le contrat architectural approuvé (v1.0.1). Cette section sera
découpée en `Ajouté` / `Modifié` / `Déprécié` / `Supprimé` / `Corrigé` au fil des lots.

### Sécurisation (Lot 0)

- **Modifié** — `ansible.cfg` ne définit plus d'inventaire par défaut. Un inventaire
  explicite (`-i`) est désormais requis pour tout playbook autonome.
- **Modifié** — `inventories/production/hosts.yml` : l'adresse d'une VM réelle a été
  remplacée par un exemple non routable (RFC 5737).
- **Ajouté** — chaque playbook autonome commence par un préflight sur `localhost` qui
  échoue explicitement, avant toute connexion, si aucun hôte `grav_servers` n'est fourni.
- **Supprimé** — lien symbolique suivi `.ansible/roles/sepp67.grav_site` (chemin local
  absolu). `.ansible/` et `/roles/` sont désormais ignorés par Git.
- **Ajouté** — garde-fous CI : aucun lien symbolique hors dépôt, aucune adresse de VM
  privée (RFC 1918) dans `inventories/`.

### Documentation et séparation (Lots 1–2)

- **Modifié** — README réécrit en français, aligné sur le contrat v1.0.1, ancres de
  section rétablies, inventaire des variables publié.
- **Ajouté** — `docs/MIGRATION.md`, `inventories/example/`, `examples/` (consommation
  externe via `requirements.yml`).
- **Supprimé** — `inventories/production/` (profil d'exploitation réel de `projet-gites`).
  Ce profil appartient désormais à un dépôt d'orchestration de l'opérateur (futur
  `grav-sites-ops`). Voir [`docs/MIGRATION.md`](docs/MIGRATION.md).
- **Modifié** — CI et `Makefile` référencent `inventories/example/` ; les cibles
  `vault-*` / `preflight` du Makefile sont paramétrées par `VAULT` / `ARGS`.

### À venir (Lots 3–9, changements d'interface — `2.0.0`)

- `grav_bind_address` deviendra **obligatoire** (sans valeur par défaut).
- Ajout de `grav_digest` (épinglage immuable optionnel) et `grav_admin_type`.
- Politique de pull par défaut : `missing` (au lieu de `always`) + `grav_force_pull`.
- Validation de forme de `grav_image` (refus d'un tag/digest incorporé, port de
  registre autorisé) et des clés de `grav_extra_environment`.
- Dépréciation de la surcharge directe des chemins dérivés (`grav_*_directory`).
- Garde contre une instance Grav laissée non initialisée (volume `accounts` vide sans
  identifiants).
- Fenêtre d'attente du healthcheck cohérente avec l'état Docker `starting` ;
  adresse du contrôle HTTP dérivée de `grav_bind_address`.
- Traçabilité structurée (`declared_version` / `digest` / `effective_reference` /
  `deployed_at`) ; fonctionnement sans `gather_facts`.
- Couverture Molecule de l'installation de Docker.

## [1.0.1] — 2026-07-25

- Arrêt du suivi des dépôts de référence (`Ressources/`).

## [1.0.0] — 2026-07-25

- Première version : rôle générique de déploiement d'une instance Grav
  (validation, Docker, volumes persistants, secrets, Docker Compose, healthcheck en
  deux temps, traçabilité de version, mise à jour et rollback manuels).
