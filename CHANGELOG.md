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

### Interface et validations (Lot 3)

#### Ruptures d'interface — `2.0.0` (voir [`docs/MIGRATION.md`](docs/MIGRATION.md))

- **RUPTURE** — `grav_bind_address` est désormais **obligatoire** (plus de défaut
  `127.0.0.1`) ; validée en forme (IPv4 stricte, `0.0.0.0`/`::`, pré-contrôle IPv6
  permissif) avant toute mutation. Voir README.md « Contrat réseau ». Un appelant
  qui n'en fournissait pas échoue explicitement. Tous les appelants internes au
  dépôt la fournissaient déjà depuis le Lot 1.
- **RUPTURE** — validation de `grav_image` durcie : refuse un tag final ou un digest
  incorporés (à mettre dans `grav_version`, ou `grav_digest` au Lot 4) ; le port d'un
  registre privé (`registry.example.net:5000/projet-grav`) reste autorisé.
- **RUPTURE** — les **clés** de `grav_extra_environment` sont désormais validées
  (`^GRAV_[A-Z0-9_]+$`) et ne peuvent plus écraser une variable déjà gérée par le
  rôle (`GRAV_ADMIN_USER`, `_PASSWORD`, `_EMAIL`, `_FULLNAME`, `_TITLE`, `_LANGUAGE`,
  `_TYPE`, `GRAV_TIMEZONE`). Une clé en minuscules, sans préfixe `GRAV_`, ou réservée,
  était acceptée avant.

#### Additifs et dépréciations

- **Ajouté** — `grav_admin_type` (`''`/`admin`/`api`/`both`, défaut `''` = le runtime
  choisit `both` ; voir `grav-runtime` `docker/bootstrap-admin.sh` lignes 62-69),
  émise dans `grav.env` comme `GRAV_ADMIN_TYPE` si non vide.
- **Déprécié** — la surcharge directe de `grav_pages_directory`, `grav_accounts_directory`,
  `grav_data_directory`, `grav_images_directory`, `grav_secret_directory` : toujours
  acceptée et honorée, mais émet un avertissement `[DEPRECATED]` si la valeur diffère
  du chemin normalement dérivé de `grav_base_directory`. Retrait éventuel en `3.0.0`.
- **Ajouté** — `tests/test_assertions.yml` (T01) : ~25 scénarios valides/invalides
  rejouant uniquement `tasks/assert.yml`, sans Docker. Intégré à la CI
  (`static-checks`).

### Déploiement et traçabilité (Lot 4)

- **Ajouté** — `grav_digest` (`""` ou `sha256:` + 64 hexa) : épinglage immuable
  optionnel. La référence Docker effective devient `grav_image@grav_digest` si un
  digest est fourni, `grav_image:grav_version` sinon — jamais `image:version@digest`.
  `grav_version` reste obligatoire (label humain). `vars/main.yml` (nouveau) porte le
  calcul de la référence effective, source unique pour le compose et la traçabilité.
- **Modifié** — politique de récupération d'image : `pull: missing` par défaut (au
  lieu de `always` sur `started`). Un redémarrage ne dépend plus de la disponibilité
  du registre si l'image est déjà présente. Nouvelle variable `grav_force_pull`
  (`false` par défaut ; `true` → `pull: always`).

- **Ajouté** — `.deployed_state.yml` : état de déploiement structuré (`image`,
  `declared_version`, `digest`, `effective_reference`, `deployed_at`) écrit à côté de
  `.deployed_version` (qui contient désormais la référence effective) et de
  `deployed_versions.log`. Le journal ajoute une ligne quand la **référence effective**
  change (version **ou** digest), jamais sur un redéploiement identique. L'historique
  existant n'est jamais supprimé.
- **Modifié** — l'horodatage de la traçabilité utilise `now(utc=true)` (heure
  contrôleur) au lieu de `ansible_date_time` : la traçabilité **fonctionne sans
  `gather_facts`** (contrat §11.6). Registres de `tasks/version.yml` préfixés `_grav_`.

### À venir (Lots 5–9, changements d'interface — `2.0.0`)

- Garde contre une instance Grav laissée non initialisée (volume `accounts` vide sans
  identifiants) — Lot 6.
- Validation IPv6 complète de `grav_bind_address` ; adresse du contrôle HTTP dérivée ;
  fenêtre d'attente du healthcheck cohérente avec l'état Docker `starting` ; crochets
  IPv6 dans le rendu Docker Compose — Lot 5.
- Couverture Molecule de l'installation de Docker — Lot 7.

## [1.0.1] — 2026-07-25

- Arrêt du suivi des dépôts de référence (`Ressources/`).

## [1.0.0] — 2026-07-25

- Première version : rôle générique de déploiement d'une instance Grav
  (validation, Docker, volumes persistants, secrets, Docker Compose, healthcheck en
  deux temps, traçabilité de version, mise à jour et rollback manuels).
