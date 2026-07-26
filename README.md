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

Le **rôle** (`defaults/`, `tasks/`, `templates/`, `meta/`) reste consommable depuis n'importe quel
autre dépôt Ansible. Ce dépôt fournit en plus, depuis sa racine, une **couche d'exploitation
autonome** (`ansible.cfg`, `playbooks/`, `inventories/production/`, `Makefile`) : après clonage et
configuration, un opérateur peut déployer une application dérivée de `grav-runtime` (ex.
`projet-gites`) directement depuis ce dépôt, sans passer par un autre dépôt Ansible — voir "Deux
façons d'utiliser ce dépôt".

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

## Deux façons d'utiliser ce dépôt

Le **rôle** (`defaults/`, `tasks/`, `templates/`, `meta/`) est et reste consommable depuis
n'importe quel autre dépôt Ansible (« Control Repository » ou autre), exactement comme avant.

Ce dépôt fournit *en plus* une **couche d'exploitation autonome** (`ansible.cfg`, `playbooks/`,
`inventories/production/`, `Makefile`) qui ne fait qu'appeler ce même rôle, sans en dupliquer la
logique : après clonage, configuration de l'inventaire et création du Vault, un opérateur peut
déployer `ghcr.io/sepp67/projet-gites` directement depuis ce dépôt, **sans dépendre de Control
Repository ni d'aucun autre dépôt Ansible**. Control Repository reste responsable de
l'infrastructure partagée (reverse proxy notamment) mais plus du site Grav lui-même — voir
"Utilisation autonome du dépôt" ci-dessous pour ce qui reste explicitement hors périmètre.

### Utilisation comme rôle réutilisable

Consommation depuis un autre dépôt Ansible (ex. Control Repository), le rôle étant installé ou
référencé comme n'importe quel autre rôle :

```yaml
# playbook du dépôt appelant
- hosts: grav_servers
  become: true
  roles:
    - role: ansible-role-grav-site   # installé via requirements.yml / ansible-galaxy, ou en submodule
      vars:
        grav_image: "ghcr.io/sepp67/projet-gites"
        grav_version: "1.0.0"
```

```ini
# inventaire du dépôt appelant
[grav_servers]
site1.example.org
```

**Mettre à jour** : changer `grav_version: "1.0.1"` (au lieu de `"1.0.0"`) et rejouer le playbook.
Le rôle télécharge la nouvelle image, recrée le conteneur, attend le healthcheck. Les répertoires
persistants (`pages`, `accounts`, `data`, `images`) sont des répertoires de l'hôte, montés en bind
mount, indépendants du cycle de vie du conteneur : ils ne sont jamais recréés ni vidés par une
mise à jour.

**Rollback** : remettre `grav_version` à sa valeur antérieure (ex. `"1.0.0"`) et rejouer le
playbook. Un rollback est, du point de vue du rôle, une mise à jour comme une autre : même
mécanisme, même garantie de non-perte des données persistantes. `{{ grav_base_directory
}}/deployed_versions.log` conserve l'historique de toutes les versions déployées (horodaté, une
ligne par changement réel de version) pour retrouver la version à laquelle revenir. **Ce rollback
est entièrement manuel** : le rôle ne détecte, ne déclenche et n'automatise aucun retour en
arrière ; un healthcheck en échec fait échouer le déploiement en cours (voir "Healthcheck") mais
ne provoque jamais, de lui-même, un retour automatique à la version précédente.

### Utilisation autonome du dépôt

Procédure complète pour déployer directement depuis ce dépôt, sans Control Repository.

**1. Cloner et installer les dépendances**

```bash
git clone <URL_DU_DEPOT>
cd ansible-role-grav-site   # ou tout autre nom : voir "Résolution du rôle"

ansible-galaxy collection install -r requirements.yml
```

**2. Configurer l'inventaire**

Éditer `inventories/production/hosts.yml` : remplacer `CHANGE_ME.example.org` et `ansible_host`
par la VM cible réelle. Éditer `inventories/production/group_vars/grav_servers/main.yml` :
remplacer `grav_version: "<VERSION_EXPLICITE>"` par un tag réellement publié sur GHCR (ex.
`"1.0.0"`) — jamais `"latest"`. `grav_image` y est déjà fixé à `ghcr.io/sepp67/projet-gites` (ce
profil d'inventaire est spécifique à `projet-gites` ; le rôle, lui, reste générique).

Ces deux fichiers sont **édités sur place, pas dupliqués vers un autre nom** — voir "Modèle ou
inventaire opérationnel ?" ci-dessous pour ce qu'il faut en faire ensuite (les commiter ou non).

**3. Créer et chiffrer le Vault**

```bash
cp inventories/production/group_vars/grav_servers/vault.yml.example \
   inventories/production/group_vars/grav_servers/vault.yml

# éditer vault.yml : renseigner vault_grav_admin_user / _password / _email au minimum
# (voir "Stratégie des secrets" ci-dessous)

ansible-vault encrypt \
   inventories/production/group_vars/grav_servers/vault.yml
```

**4. Vérifications préalables (préflight)**

Voir "Préflight" ci-dessous — au minimum, tester la connectivité :

```bash
ansible grav_servers -m ping --ask-vault-pass
```

**5. Déployer**

```bash
ansible-playbook playbooks/deploy.yml --ask-vault-pass
# ou : make deploy ARGS=--ask-vault-pass
```

`--ask-vault-pass` (ou `--vault-password-file`) n'est nécessaire que parce que `vault.yml` est
chiffré ; omettez-le uniquement si vous utilisez un autre mécanisme de décryptage Vault (agent,
fichier de mot de passe configuré dans `ansible.cfg`, etc.).

**6. Vérifier**

```bash
ansible-playbook playbooks/check.yml --ask-vault-pass
```

N'installe rien, ne modifie rien : relit le healthcheck Docker et vérifie qu'une page réelle du
site répond (mêmes tâches que celles exécutées automatiquement à la fin d'un déploiement).

**7. Mettre à jour**

Modifier `grav_version` dans `inventories/production/group_vars/grav_servers/main.yml`, puis :

```bash
ansible-playbook playbooks/deploy.yml --ask-vault-pass
```

**8. Rollback**

Remettre `grav_version` à sa valeur antérieure dans le même fichier, puis rejouer
`playbooks/deploy.yml` — voir "Rollback" ci-dessus (entièrement manuel, mêmes garanties).

**9. Arrêter / redémarrer**

```bash
ansible-playbook playbooks/stop.yml --ask-vault-pass       # ou : make stop
ansible-playbook playbooks/restart.yml --ask-vault-pass    # ou : make restart
```

### `inventories/production/` : modèle ou inventaire opérationnel ?

Les deux, selon le dépôt où on se trouve — pas d'ambiguïté une fois cette distinction posée :

- **Dans le dépôt canonique publié** (celui que d'autres opérateurs clonent), `inventories/
  production/` est un **modèle** : `hosts.yml` et `main.yml` contiennent des valeurs
  volontairement invalides (`CHANGE_ME.example.org`, `<VERSION_EXPLICITE>`). Ce dépôt canonique
  n'est **jamais lui-même pointé vers une VM réelle** et n'est **jamais déployé tel quel**.
- **Une fois cloné pour un déploiement réel** (étape 1 ci-dessus), `hosts.yml` et `main.yml` sont
  **édités sur place** (jamais copiés vers un autre nom — contrairement à `vault.yml.example`,
  ils ne contiennent aucun secret, rien n'impose une distinction fichier-modèle / fichier-réel).
  Une fois édités, ils **deviennent l'inventaire opérationnel de ce déploiement précis** : hostname
  réel, `grav_version` réellement déployée.
- Ces fichiers édités sont faits pour être **commités dans le clone de l'opérateur** (son propre
  fork ou dépôt d'exploitation dédié à ce site) — **jamais repoussés vers le dépôt canonique en
  amont**, qui doit rester un modèle générique pour d'autres opérateurs. Commiter
  `inventories/production/` une fois configuré est un choix délibéré, pas un oubli : `git log` /
  `git diff` sur `group_vars/grav_servers/main.yml` devient la trace auditable de "quelle version
  est déployée depuis quand" (cohérent avec `deployed_versions.log`, tenu côté hôte cible). Aucun
  secret n'y transite jamais, dans aucun des deux dépôts : `vault.yml` reste exclu par
  `.gitignore` quel que soit le clone (voir "Stratégie des secrets").
- **Pour déployer un second site** depuis le même clone (autre application dérivée de
  `grav-runtime`, ou même application sur une autre VM), dupliquer le dossier
  (`inventories/<autre-nom>/`) plutôt que ré-éditer `inventories/production/` par-dessus — chaque
  site garde ainsi son propre profil versionné indépendamment (voir le commentaire dans
  `hosts.yml`).

### Hors périmètre (usage autonome comme usage en rôle réutilisable)

- **Control Repository n'est plus requis pour déployer le site** : ce dépôt, une fois cloné et
  configuré, suffit intégralement à créer, mettre à jour, arrêter, redémarrer et diagnostiquer
  l'instance. Control Repository peut continuer à exister pour l'infrastructure partagée, mais
  n'a plus aucune responsabilité sur le site Grav lui-même.
- **Le reverse proxy reste hors périmètre.** Ce rôle publie le service en HTTP sur
  `{{ grav_bind_address }}:{{ grav_http_port }}` — `127.0.0.1:8080` par défaut. Un reverse proxy
  installé séparément (par Control Repository ou autrement) peut cibler ce port ; TLS et le nom de
  domaine public sont sa responsabilité, jamais celle de ce dépôt.
- **Le DNS reste hors périmètre.**
- **Le pare-feu reste hors périmètre.**
- **L'image doit déjà être publiée sur un registre (GHCR)** : ce dépôt ne construit ni ne publie
  jamais d'image (voir "Ce que le rôle ne fait jamais").
- **Un changement de version se fait uniquement par modification explicite de `grav_version`**
  (jamais automatique, jamais implicite via `latest`).

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

### Stratégie des secrets (usage autonome)

L'inventaire `inventories/production/` (voir "Utilisation autonome du dépôt") applique une
convention explicite pour ne jamais exposer de valeur sensible dans un fichier non chiffré :

1. `group_vars/grav_servers/vault.yml` (chiffré, jamais commité en clair — voir `.gitignore`)
   définit chaque secret sous un nom **préfixé `vault_`** : `vault_grav_admin_password`,
   `vault_grav_admin_user`, etc. — voir `vault.yml.example` pour la liste complète.
2. `group_vars/grav_servers/main.yml` (non chiffré, versionné) affecte explicitement chaque
   variable attendue par le rôle à la variable Vault correspondante :

   ```yaml
   grav_admin_password: "{{ vault_grav_admin_password }}"
   ```

Cette indirection à sens unique (jamais l'inverse) évite trois problèmes classiques : aucune
collision de nom entre les deux jeux de variables, aucune récursion Jinja (`grav_admin_password`
ne référence jamais `grav_admin_password`), et aucune valeur sensible ne peut se retrouver dans un
fichier non chiffré par erreur — `main.yml` ne contient que des références, jamais une valeur.

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

## Résolution du rôle

`playbooks/deploy.yml`, `stop.yml`, `restart.yml` et `check.yml` référencent le rôle par
**chemin relatif au fichier playbook lui-même** (`{{ playbook_dir }}/..`), jamais par son nom.
Ce dépôt EST le rôle (`tasks/`, `defaults/`, `templates/`, `meta/` à sa racine) : `playbooks/`
n'est qu'un niveau en dessous, donc `{{ playbook_dir }}/..` désigne toujours la racine du dépôt,
**quel que soit le nom du dossier sous lequel ce dépôt a été cloné**. Vérifié empiriquement
(bac à sable avec un dossier de clone nommé arbitrairement) : la résolution fonctionne à
l'identique avec `roles:` et avec `include_role`.

`ansible.cfg` définit bien `roles_path`, mais celui-ci n'intervient à aucun moment dans la
résolution de CE rôle par les playbooks de ce dépôt — il n'est là que pour un éventuel rôle tiers
ajouté un jour via `requirements.yml`. `tests/test.yml` et `tests/test_env_encoding.yml` utilisent
la même résolution par chemin relatif, pour la même raison.

## Préflight

Avant un premier déploiement, vérifier :

| Point | Commande |
|---|---|
| Version d'Ansible supportée | `ansible --version` (voir "Prérequis" : ansible-core ≥ 2.17, < 2.18) |
| Collection `community.docker` installée | `ansible-galaxy collection install -r requirements.yml` puis `ansible-galaxy collection list community.docker` |
| Connectivité SSH vers la cible | `ansible grav_servers -m ping` |
| `become` fonctionnel sur la cible | `ansible grav_servers -b -m command -a "whoami"` (doit répondre `root`) |
| Architecture de la cible supportée | `ansible grav_servers -m setup -a "filter=ansible_architecture"` (x86_64 ou aarch64 si `grav_manage_docker: true`) |
| Registre GHCR joignable depuis la cible | `ansible grav_servers -m uri -a "url=https://ghcr.io/v2/ status_code=200,401"` |
| Fichier Vault présent | `test -f inventories/production/group_vars/grav_servers/vault.yml` |

`make preflight` exécute ces sept vérifications d'un coup (voir "Makefile"). Aucune de ces
vérifications ne duplique ce que le rôle valide déjà lui-même à l'exécution (Docker/Compose : voir
`tasks/verify_docker.yml` ; variables obligatoires : voir `tasks/assert.yml`) — elles couvrent
uniquement ce qui précède l'exécution du rôle (accès à la machine, au registre).

## Makefile

Point d'entrée ergonomique optionnel, qui se contente d'appeler Ansible et les outils standards
(aucune logique propre, aucun paramètre masqué) :

| Cible | Équivalent |
|---|---|
| `make dependencies` | `ansible-galaxy collection install -r requirements.yml` |
| `make lint` | `ansible-lint . playbooks/ inventories/` |
| `make preflight` | voir "Préflight" ci-dessus |
| `make deploy` | `ansible-playbook playbooks/deploy.yml` |
| `make check` | `ansible-playbook playbooks/check.yml` |
| `make stop` | `ansible-playbook playbooks/stop.yml` |
| `make restart` | `ansible-playbook playbooks/restart.yml` |
| `make vault-edit` | `ansible-vault edit inventories/production/group_vars/grav_servers/vault.yml` |
| `make vault-view` | `ansible-vault view inventories/production/group_vars/grav_servers/vault.yml` |

Toute cible acceptant des arguments Ansible supplémentaires (`--ask-vault-pass`, `--limit`,
`--check --diff`, `-i` un autre inventaire...) les accepte via `ARGS`, ex. :
`make deploy ARGS=--ask-vault-pass`.

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
ansible-lint . playbooks/ inventories/   # playbooks/ et inventories/ ne sont pas auto-découverts, voir Makefile
cd tests
ansible-playbook -i inventory test.yml
ansible-playbook -i inventory test_env_encoding.yml
ansible-playbook -i inventory test_standalone.yml
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

`tests/test_standalone.yml` exécute réellement `playbooks/deploy.yml`, `check.yml`, `restart.yml`
et `stop.yml` (les vrais fichiers, en sous-processus `ansible-playbook`, pas une copie) depuis un
inventaire de test dédié (`tests/inventory_grav_servers`, groupe `grav_servers` → localhost) :
déploie, vérifie l'image en exécution, vérifie sans changer d'état, redémarre, arrête, vérifie que
les données persistantes survivent — la preuve que la couche autonome fonctionne réellement depuis
la racine du dépôt, sans Control Repository. `-e ansible_become=false` y désactive `become` pour ce
test précis (voir commentaire en tête du fichier) ; les playbooks livrés gardent `become: true`.

`grav_manage_docker: false` est utilisé dans les trois fichiers pour ne pas modifier la machine de
test — la partie installation de Docker (`tasks/docker.yml`) doit être validée séparément, avec
les privilèges root, sur un hôte Debian/Ubuntu vierge.

Aucun de ces trois tests ne lance de déploiement de production réel : hôte local uniquement,
images publiques génériques, nettoyage complet en fin d'exécution.

### Vérifications statiques de la couche autonome

En complément (voir `.github/workflows/ci.yml`, job `static-checks`), sans Docker :

```bash
# Syntaxe de chaque playbook autonome
for p in playbooks/*.yml; do
  ansible-playbook --syntax-check -i inventories/production/hosts.yml "$p"
done

# Validité de l'inventaire de production (exemple)
ansible-inventory -i inventories/production/hosts.yml --list >/dev/null

# grav_version de l'exemple jamais "latest"
! grep -E '^\s*grav_version:\s*"?latest"?\s*$' \
  inventories/production/group_vars/grav_servers/main.yml

# Aucun vault.yml réel commité (seul vault.yml.example doit exister)
test ! -f inventories/production/group_vars/grav_servers/vault.yml
test -f inventories/production/group_vars/grav_servers/vault.yml.example

# Aucune référence à Control Repository ou à un chemin de développement local
! grep -rniE 'control[_-]repo|/home/[a-z]+/' \
  --include='*.yml' --include='*.yaml' --include='*.cfg' --include='Makefile' \
  --exclude-dir=Ressources --exclude-dir=.git .
```

## Limitations connues

- Installation de Docker limitée à Debian/Ubuntu (voir "Systèmes supportés").
- Pas de gestion d'authentification registre (`docker login`) — l'image doit être publique. À
  ajouter si un registre privé devient nécessaire.
- Le rôle ne conserve pas automatiquement les images des versions précédentes en local : un
  rollback re-télécharge l'image depuis le registre si elle n'est plus présente localement — le
  registre (GHCR) est la source de vérité pour les versions disponibles, pas l'hôte.

## Licence

MIT
