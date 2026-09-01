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
  `deployed_versions.log`. Le journal (`<horodatage> <declared_version> <référence
  effective>`) ajoute une ligne quand l'**état contractuel** change —
  `declared_version`, `digest` ou référence effective : une nouvelle version derrière
  un digest identique (ex. `1.0.7` → `1.0.8`, même `sha256`) est journalisée. Jamais
  sur un redéploiement strictement identique. L'historique existant n'est jamais
  supprimé.
- **Modifié** — l'horodatage de la traçabilité utilise `now(utc=true)` (heure
  contrôleur) au lieu de `ansible_date_time` : la traçabilité **fonctionne sans
  `gather_facts`** (contrat §11.6). Registres de `tasks/version.yml` préfixés `_grav_`.

### Réseau et santé (Lot 5)

- **RUPTURE** — `grav_bind_address` : validation restreinte à l'**IPv4 stricte**
  (octets 0–255, sans zéro initial, 4 octets) ou `0.0.0.0`. L'**IPv6 est refusée** en
  `2.0.0` (dont `::`) — une validation IPv6 fiable exigerait `ansible.utils` +
  `netaddr`. Le pré-contrôle permissif du Lot 3 (« toute chaîne contenant `:` ») est
  supprimé.
- **Modifié** — `grav_site_check_host` : défaut `127.0.0.1` → `""`. L'adresse du
  contrôle HTTP applicatif est désormais **dérivée** de `grav_bind_address` (adresse
  précise → la même ; `0.0.0.0` → `127.0.0.1`), calcul porté par `vars/main.yml`
  (`_grav_site_check_host`). Un override explicite reste possible mais ne peut plus
  contenir `:` (ni IPv6, ni port).
- **Corrigé** — l'attente du healthcheck (`tasks/healthcheck.yml`) sort désormais de
  sa boucle sur un **verdict Docker définitif** (`healthy` ou `unhealthy`), plus
  jamais sur un simple `starting` : un conteneur encore légitimement en démarrage ne
  produit plus de faux échec. La fenêtre passe à `60 × 5 = 300 s`
  (`grav_deploy_wait_retries` `30` → `60`, `grav_deploy_wait_delay` `2` → `5`) et
  `tasks/assert.yml` impose un plancher de `120 s` (> `start_period` + `interval` ×
  `retries` du healthcheck par défaut).
- **Corrigé** — chemin d'échec (`rescue`) : les logs du conteneur ne sont plus
  déversés dans la sortie Ansible. Ils sont capturés avec `no_log` et écrits dans
  `{{ grav_base_directory }}/.last_failure.log` (mode `0600`, root) ; le message
  d'erreur, lui, reste lisible et renvoie vers ce fichier.

### À venir (Lots 6–9, changements d'interface — `2.0.0`)

- Garde contre une instance Grav laissée non initialisée (volume `accounts` vide sans
  identifiants) — Lot 6.
- Couverture Molecule de l'installation de Docker — Lot 7.

## [1.0.1] — 2026-07-25

- Arrêt du suivi des dépôts de référence (`Ressources/`).

## [1.0.0] — 2026-07-25

- Première version : rôle générique de déploiement d'une instance Grav
  (validation, Docker, volumes persistants, secrets, Docker Compose, healthcheck en
  deux temps, traçabilité de version, mise à jour et rollback manuels).
