# ansible-role-grav-site

Rôle Ansible générique pour déployer un site basé sur [`grav-runtime`](https://github.com/sepp67/grav-runtime)
(Grav CMS dans Nginx + PHP-FPM, packagé en une seule image Docker).

Ce rôle **ne construit et ne modifie jamais d'image Docker**. Il consomme une image déjà publiée
sur un registre (ex. GHCR), dérivée de `grav-runtime`. Changer d'application déployée ne
nécessite de modifier que deux variables : `grav_image` et `grav_version`. Aucun thème, plugin,
page, photo ou configuration métier ne fait partie de ce rôle, ni ne doit jamais en faire partie.

```text
grav-runtime (socle générique)
    └── projet-gites, grav-docs, ... (images applicatives filles, publiées sur un registre)
            └── ansible-role-grav-site (ce rôle : déploie n'importe laquelle de ces images)
```

## Ce que fait le rôle

- Installe Docker Engine et le plugin Docker Compose si nécessaire (Debian/Ubuntu).
- Crée les répertoires persistants et le répertoire des secrets sur l'hôte.
- Génère un `docker-compose.yml` et un `grav.env` génériques (aucune donnée propre à un projet).
- Monte les répertoires persistants et les fichiers secrets.
- Télécharge l'image et démarre le conteneur.
- Attend que le conteneur soit `healthy`, puis vérifie qu'une page réelle du site répond.
- Enregistre la version déployée (marqueur + journal).
- Permet une mise à jour ou un rollback : changer `grav_version` et rejouer le rôle.

## Ce que le rôle ne fait jamais

Construire ou modifier une image, copier des pages/thèmes/plugins/médias métier, exécuter Grav
CLI, créer un compte administrateur autrement que via les variables du contrat `grav-runtime`,
gérer un reverse proxy, TLS, le DNS, un VPN ou un pare-feu. Ces responsabilités sont hors périmètre
par conception — voir "Contrat avec grav-runtime" ci-dessous.

## Prérequis

- Un hôte Debian ou Ubuntu x86_64 ou aarch64 (voir "Systèmes supportés").
- Ansible-core ≥ 2.17, < 2.18, exécuté avec les privilèges root (`become: true`) — le rôle
  installe des paquets système et écrit sous `/opt` par défaut. Cette borne suit celle de
  `community.docker` 5.x (voir "Tests" / `requirements.yml`) : la collection ne fonctionne pas
  avec un ansible-core plus ancien.
- La collection `community.docker` (>=5.0.0,<6.0.0) :

```bash
ansible-galaxy collection install -r requirements.yml
```
- Le plugin Docker Compose officiel (`docker-compose-plugin`, installé automatiquement par ce
  rôle) doit supporter `env_file: format: raw` — vérifié avec la version 5.3.1 ; toute version
  installée depuis le dépôt APT officiel Docker (voir `tasks/docker.yml`) convient.

## Systèmes supportés

Debian et Ubuntu uniquement (`tasks/docker.yml` utilise le dépôt APT officiel Docker). Sur un
autre OS, mettez `grav_manage_docker: false` et installez Docker Engine + le plugin Docker Compose
vous-même avant d'appliquer ce rôle — le reste du rôle (répertoires, compose, secrets,
healthcheck, version) reste indépendant de l'OS.

## Playbook minimal

```yaml
- hosts: grav_servers
  become: true
  roles:
    - role: ansible-role-grav-site
      vars:
        grav_image: "ghcr.io/sepp67/projet-gites"
        grav_version: "1.0.0"
```

## Inventaire minimal

```ini
[grav_servers]
site1.example.org
```

## Mettre à jour vers une nouvelle version

```yaml
        grav_version: "1.0.1"   # au lieu de "1.0.0"
```

Rejouez le playbook. Le rôle télécharge la nouvelle image, recrée le conteneur, attend le
healthcheck. Les répertoires persistants (`pages`, `accounts`, `data`, `images`) sont des
répertoires de l'hôte, montés en bind mount, indépendants du cycle de vie du conteneur : ils ne
sont jamais recréés ni vidés par une mise à jour.

## Revenir à une version précédente (rollback)

```yaml
        grav_version: "1.0.0"   # valeur antérieure
```

Rejouez le playbook. Un rollback est, du point de vue du rôle, une mise à jour comme une autre :
même mécanisme, même garantie de non-perte des données persistantes. `{{ grav_base_directory
}}/deployed_versions.log` conserve l'historique de toutes les versions déployées (avec horodatage,
une ligne par changement réel de version — jamais dupliqué par un simple redéploiement identique)
pour retrouver la version à laquelle revenir.

**Ce rollback est entièrement manuel.** Le rôle ne détecte, ne déclenche et n'automatise aucun
retour en arrière : c'est à l'opérateur de choisir la version cible (dans
`deployed_versions.log`) et de rejouer explicitement le playbook avec ce `grav_version`. Un
healthcheck en échec fait échouer le déploiement en cours (voir "Healthcheck") mais ne provoque
jamais, de lui-même, un retour automatique à la version précédente.

## Variables

### Identité de l'application (obligatoires)

| Variable | Description |
|---|---|
| `grav_image` | Image applicative dérivée de `grav-runtime` (ex. `ghcr.io/sepp67/projet-gites`) |
| `grav_version` | Tag de version à déployer |

Ce sont les **deux seules variables** à modifier pour déployer une application différente.

### Instance et réseau

| Variable | Défaut | Description |
|---|---|---|
| `grav_container_name` | `grav-site` | Nom du conteneur/service — validé (`^[A-Za-z0-9][A-Za-z0-9._-]*$`, ni `..`, `/` ni `:`) |
| `grav_base_directory` | `/opt/grav-site/{{ grav_container_name }}` | Racine de l'instance sur l'hôte |
| `grav_bind_address` | `127.0.0.1` | Interface d'écoute hôte — le rôle ne gérant ni reverse proxy ni TLS, le port n'est publié qu'en local par défaut |
| `grav_http_port` | `8080` | Port hôte publié vers le port 80 du conteneur — validé (1-65535) |
| `grav_restart_policy` | `unless-stopped` | Politique de redémarrage Docker |
| `grav_state` | `started` | `started` / `stopped` / `restarted` — validé |

`grav_version` est également validé : jamais `"latest"` (voir "Versionnement" dans le contrat
grav-runtime). Toutes ces validations s'exécutent avant toute action (`tasks/assert.yml`) et font
échouer le rôle avec un message explicite plutôt que de laisser Docker/Compose échouer plus loin.

### Répertoires persistants

| Variable | Défaut | Monté sur (dans le conteneur) |
|---|---|---|
| `grav_pages_directory` | `{{ grav_base_directory }}/data/pages` | `/var/www/html/user/pages` |
| `grav_accounts_directory` | `{{ grav_base_directory }}/data/accounts` | `/var/www/html/user/accounts` |
| `grav_data_directory` | `{{ grav_base_directory }}/data/data` | `/var/www/html/user/data` |
| `grav_images_directory` | `{{ grav_base_directory }}/data/images` | `/var/www/html/user/images` |

Ces 4 répertoires sont créés sans propriétaire ni mode imposés : `grav-runtime` reprend lui-même
leur propriété (`www-data`, uid/gid 82) et fixe les droits à son premier démarrage (voir
`entrypoint.sh` du runtime). Le rôle ne doit jamais tenter d'imposer un mode à chaque exécution :
une fois la propriété reprise par le conteneur, un utilisateur non-root ne peut plus les chmoder —
constaté en test, voir `tasks/directories.yml`.

### Secrets

| Variable | Défaut | Description |
|---|---|---|
| `grav_secret_directory` | `{{ grav_base_directory }}/secrets` | Répertoire des secrets sur l'hôte |
| `grav_secrets` | `[]` | Liste de fichiers à monter individuellement en lecture seule sous `user/config/` — `name` validé comme `grav_container_name` ci-dessus |
| `grav_container_gid` | `82` | GID interne de `www-data` dans `grav-runtime` (image Alpine) — permet aux secrets d'être lisibles par PHP-FPM sans bit "other" |

Chaque entrée de `grav_secrets` fournit `name` et exactement l'un de `src` (fichier local, à
chiffrer avec `ansible-vault`) ou `content` (contenu inline, à vaultiser) :

```yaml
grav_secrets:
  - name: security-private.php
    src: "{{ inventory_dir }}/files/security-private.php"   # ansible-vault encrypt ...
  - name: email-private.php
    content: "{{ vaulted_email_private_php }}"
```

### Bootstrap administrateur

| Variable | Description |
|---|---|
| `grav_admin_user` / `grav_admin_password` / `grav_admin_email` | Transmis tels quels au runtime — **toutes les trois ou aucune** (voir "Contrat avec grav-runtime") |
| `grav_admin_fullname` / `grav_admin_title` / `grav_admin_language` | Optionnels |
| `grav_timezone` | `date.timezone` PHP |

`grav_admin_password` doit provenir d'`ansible-vault`, jamais être commité en clair.

### Échappatoire générique

| Variable | Défaut | Description |
|---|---|---|
| `grav_extra_environment` | `{}` | Dict libre de variables d'environnement additionnelles, transmises telles quelles au conteneur — pour une future version de `grav-runtime` sans modifier ce rôle |

### Healthcheck

| Variable | Défaut | Description |
|---|---|---|
| `grav_healthcheck_interval` / `_timeout` / `_start_period` / `_retries` | `30s` / `3s` / `10s` / `3` | Paramètres du `HEALTHCHECK` déclaré dans le compose (mêmes valeurs que celles déjà définies dans l'image) |
| `grav_deploy_wait_retries` / `_delay` | `30` / `2` | Attente côté Ansible du statut Docker `healthy` — `_retries` validé (> 0) |
| `grav_site_check_host` | `127.0.0.1` | Adresse ciblée par la vérification HTTP — **volontairement distincte** de `grav_bind_address` (qui peut valoir `0.0.0.0`, non joignable en tant que destination) ; validé non vide |
| `grav_site_check_path` | `/` | Page réelle du site à vérifier en plus de `/healthz` — validé, doit commencer par `/` |
| `grav_site_check_status` | `200` | Code HTTP attendu |
| `grav_site_check_retries` / `_delay` / `_timeout` | `10` / `5` / `5` | Paramètres d'attente de la vérification HTTP |

### Installation de Docker

| Variable | Défaut | Description |
|---|---|---|
| `grav_manage_docker` | `true` | Installer Docker Engine + le plugin Compose (Debian/Ubuntu, x86_64/aarch64 uniquement) |

Quand `grav_manage_docker: false`, le rôle ne suppose pas silencieusement que Docker est prêt : il
vérifie explicitement (`docker version`, `docker compose version`) et échoue clairement si l'un
des deux manque (`tasks/verify_docker.yml`).

## Structure des dossiers déployés sur l'hôte

```text
{{ grav_base_directory }}/
├── docker-compose.yml       # généré, générique — ne pas éditer à la main
├── grav.env                 # généré, mode 0600 — variables du contrat grav-runtime (format raw)
├── secrets/                 # fichiers secrets, montés individuellement en lecture seule
│   └── security-private.php
├── data/
│   ├── pages/                # bind mount user/pages
│   ├── accounts/              # bind mount user/accounts
│   ├── data/                 # bind mount user/data
│   └── images/                # bind mount user/images
├── .deployed_version         # image:version actuellement déployée
└── deployed_versions.log     # historique horodaté de tous les déploiements
```

`user/themes` et `user/plugins` ne sont **pas** des volumes : ils sont fournis par l'image et
changent par changement d'image, jamais par ce rôle.

## Contrat avec `grav-runtime`

Ce rôle s'appuie sur le contrat exposé par `grav-runtime` sans jamais le remettre en cause :

- Une image applicative dérivée de `grav-runtime:<version>`, taguée explicitement.
- Port `80/tcp` HTTP uniquement — aucun TLS (géré par un reverse proxy externe, hors périmètre).
- Variables d'environnement : `GRAV_ADMIN_USER` / `_PASSWORD` / `_EMAIL` (toutes ou aucune),
  `GRAV_ADMIN_FULLNAME`, `_TITLE`, `_LANGUAGE`, `GRAV_TIMEZONE`.
- 4 répertoires persistants montables séparément : `user/pages`, `user/accounts`, `user/data`,
  `user/images`. Le runtime les initialise lui-même depuis son répertoire seed interne au premier
  démarrage, indépendamment par sous-répertoire — le rôle n'a rien à faire ici au-delà de fournir
  des répertoires (vides ou déjà peuplés).
- `HEALTHCHECK` Docker natif sur `GET /healthz` (technique, ne passe jamais par Grav) — le rôle
  attend ce statut puis vérifie en plus une page réelle, comme demandé explicitement par le README
  du runtime.
- Redémarrage propre sur `SIGTERM` (`docker stop` / `docker compose down`/`stop`).

## Contrat avec une image applicative

Une image applicative valide pour ce rôle :

- Dérive de `grav-runtime:<version>` par `FROM`.
- N'ajoute que du contenu métier (thème, plugins, configuration versionnée, seed initial) — jamais
  de secret, jamais de compte, jamais de configuration d'environnement réelle codée en dur.
- N'attend aucune variable d'environnement en dehors de celles du contrat `grav-runtime`
  ci-dessus, sauf via `grav_extra_environment` si une nouvelle version du runtime en introduit.

Si ces conditions sont respectées, déployer une application différente ne nécessite que de changer
`grav_image` et `grav_version` — aucune autre variable, aucun autre fichier.

## Tests

```bash
ansible-galaxy collection install -r requirements.yml
ansible-lint .
cd tests
ansible-playbook -i inventory test.yml
ansible-playbook -i inventory test_env_encoding.yml
```

`tests/test.yml` déploie deux versions publiques réelles et distinctes de `grav-runtime` (aucun
contenu métier) selon une séquence qui distingue explicitement chaque cas, avec vérification de
l'image réellement en exécution (`docker inspect --format='{{.Config.Image}}'`) à chaque étape :

1. Déploie la version A → image en exécution = A, dépose un marqueur dans `user/pages`.
2. Redéploie **la même version A** → image toujours A, marqueur intact, **aucune nouvelle ligne**
   dans `deployed_versions.log` (vérifie l'idempotence de la journalisation).
3. Met à jour vers la version B → image devenue B, marqueur intact, **+1 ligne** dans le journal.
4. Revient (rollback) vers la version A → image redevenue A, marqueur intact, **+1 ligne**.

`tests/test_env_encoding.yml` déploie avec un mot de passe admin contenant `$`, `#`, des espaces,
des guillemets doubles et simples, et un antislash, puis vérifie via `docker exec ... printenv`
que la valeur ressort **strictement identique** (comparaison sous `no_log: true`, la valeur n'est
jamais affichée).

`grav_manage_docker: false` est utilisé dans les deux fichiers pour ne pas modifier la machine de
test — la partie installation de Docker (`tasks/docker.yml`) doit être validée séparément, avec
les privilèges root, sur un hôte Debian/Ubuntu vierge.

`tests/ansible.cfg` pointe `roles_path` vers le parent du dépôt, ce qui permet à Ansible de
résoudre le rôle par le nom de son propre répertoire (`ansible-role-grav-site`), sans copie ni
symlink.

## Limitations connues

- Installation de Docker limitée à Debian/Ubuntu (voir "Systèmes supportés").
- Pas de gestion d'authentification registre (`docker login`) — l'image doit être publique. À
  ajouter si un registre privé devient nécessaire.
- Le rôle ne conserve pas automatiquement les images des versions précédentes en local : un
  rollback re-télécharge l'image depuis le registre si elle n'est plus présente localement — le
  registre (GHCR) est la source de vérité pour les versions disponibles, pas l'hôte.

## Licence

MIT
