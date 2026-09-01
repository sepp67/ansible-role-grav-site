# ansible-role-grav-site

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Ansible](https://img.shields.io/badge/Ansible-2.17-red)](https://docs.ansible.com/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue)](https://docs.docker.com/compose/)

Rôle Ansible générique qui déploie **exactement une instance Grav par invocation**,
à partir d'une image applicative dérivée de
[`grav-runtime`](https://github.com/sepp67/grav-runtime) (Grav CMS dans Nginx + PHP-FPM,
packagé en une seule image Docker).

Ce rôle **ne construit ni ne modifie jamais d'image Docker**. Il consomme une image
déjà publiée sur un registre (ex. GHCR). Il ne contient aucun thème, plugin, page,
média ou configuration métier, et ne doit jamais en contenir.

```text
grav-runtime (socle générique)
    └── projet-gites, projet-lavallee, … (images applicatives, publiées sur un registre)
            └── ansible-role-grav-site (ce rôle : déploie l'une de ces images sur une VM)
                    └── grav-sites-ops (à venir : décrit le parc, invoque ce rôle)
```

Le `control-repository` (Caddy, domaines, TLS) est **parallèle** à cette chaîne : il
publie sur Internet des instances déjà joignables sur le réseau local, sans dépendre
de ce dépôt ni de `grav-sites-ops`.

> **Évolution vers `v2.0.0`** — ce rôle est en cours de refonte selon un contrat
> architectural approuvé. `grav_bind_address` est déjà obligatoire (voir
> "Contrat réseau"). Restent à venir : support d'un digest, politique de pull
> `missing`. Voir [`CHANGELOG.md`](CHANGELOG.md) et
> [`docs/MIGRATION.md`](docs/MIGRATION.md). Ce README décrit le comportement
> **actuel** du rôle.

---

## Ce que fait le rôle

1. Valide toutes les variables structurantes **avant toute action** (`tasks/assert.yml`).
2. Installe Docker Engine + le plugin Docker Compose si demandé (Debian/Ubuntu).
3. Crée la racine de l'instance, les 4 répertoires persistants et le répertoire des secrets.
4. Installe les fichiers secrets fournis par l'appelant (jamais générés).
5. Génère un `docker-compose.yml` et un `grav.env` génériques.
6. Récupère l'image demandée et applique l'état voulu au conteneur.
7. Attend le statut Docker `healthy`, puis vérifie qu'une page réelle du site répond.
8. Enregistre la version déployée (`.deployed_version` + `deployed_versions.log`).

Une mise à jour ou un rollback consistent à changer `grav_version` et à rejouer le rôle.

## Ce que le rôle ne fait jamais

Construire ou modifier une image ; embarquer du contenu métier ; gérer le parc de sites,
l'affectation site → VM, ni les versions applicatives de plusieurs sites ; choisir la
version de `grav-runtime` (elle est figée dans le `Dockerfile` de l'image applicative) ;
gérer un reverse proxy, TLS, le DNS ou un pare-feu ; appeler `grav-sites-ops` ou le
`control-repository` ni générer leur configuration ; synchroniser du contenu entre Git
et les volumes ; sauvegarder ou restaurer des données ; effectuer un rollback automatique.

## Systèmes supportés

Debian et Ubuntu uniquement lorsque `grav_manage_docker: true` (`tasks/docker.yml`
utilise le dépôt APT officiel Docker), architectures `x86_64` / `aarch64`.

| Distribution | Testée en CI |
|---|---|
| Debian 12 (bookworm) | oui (à venir, refonte `v2`) |
| Ubuntu 22.04 (jammy) | oui (à venir, refonte `v2`) |
| Ubuntu 24.04 (noble) | oui (à venir, refonte `v2`) |

Sur un autre OS : `grav_manage_docker: false` et installez Docker Engine + le plugin
Docker Compose vous-même. Le reste du rôle est indépendant de l'OS.

## Prérequis

- Ansible-core `>= 2.17, < 2.18` (borne alignée sur `community.docker` 5.x), exécuté
  avec les privilèges root (`become: true`).
- La collection `community.docker` (`>=5.0.0,<6.0.0`) :

  ```bash
  ansible-galaxy collection install -r requirements.yml
  ```

- Le plugin Docker Compose officiel doit supporter `env_file: format: raw`.

---

## Deux façons d'utiliser ce dépôt

### Utilisation comme rôle réutilisable (mode cible)

Consommation depuis un autre dépôt Ansible (ex. le futur `grav-sites-ops`), le rôle
étant **épinglé sur un tag Git** via `requirements.yml` — voir [`examples/`](examples/) :

```yaml
# requirements.yml du dépôt appelant
roles:
  - name: grav_site
    src: git+https://github.com/sepp67/ansible-role-grav-site.git
    version: "v2.0.0"
```

```yaml
# playbook du dépôt appelant
- hosts: grav_servers
  become: true
  roles:
    - role: grav_site
      vars:
        grav_image: "ghcr.io/sepp67/projet-gites"
        grav_version: "1.0.7"
```

Le dépôt appelant fournit l'inventaire, les valeurs propres au site et à la VM, et les
secrets. Il **ne dépend jamais de l'arborescence interne de ce dépôt**.

### Utilisation autonome du dépôt

Ce dépôt fournit *en plus*, depuis sa racine, une **couche d'exploitation autonome
générique** (`ansible.cfg`, `playbooks/`, `Makefile`, `inventories/example/`) qui ne
fait qu'appeler ce même rôle, sans en dupliquer la logique. Elle permet de déployer
**un seul site** sans dépendre d'aucun autre dépôt.

Ce dépôt **ne cible aucune VM par défaut** : un inventaire explicite est toujours requis.

**1. Cloner et installer les dépendances**

```bash
git clone <URL_DU_DEPOT>
cd ansible-role-grav-site   # ou tout autre nom : voir "Résolution du rôle"
ansible-galaxy collection install -r requirements.yml
```

**2. Créer votre inventaire à partir du modèle**

```bash
cp -r inventories/example inventories/mon-site
```

Éditez `inventories/mon-site/hosts.yml` (adresse réelle de votre VM) et
`inventories/mon-site/group_vars/grav_servers/main.yml` (au minimum `grav_image` et
`grav_version` — jamais `"latest"`).

**3. Créer et chiffrer le Vault**

```bash
cp inventories/mon-site/group_vars/grav_servers/vault.yml.example \
   inventories/mon-site/group_vars/grav_servers/vault.yml
# éditez vault.yml : vault_grav_admin_user / _password / _email (voir "Stratégie des secrets")
ansible-vault encrypt inventories/mon-site/group_vars/grav_servers/vault.yml
```

`vault.yml` est exclu par `.gitignore` dans tout clone.

**4. Préflight** — voir "Préflight" ci-dessous :

```bash
make preflight ARGS="-i inventories/mon-site/hosts.yml --ask-vault-pass"
```

**5. Déployer / vérifier / mettre à jour / arrêter**

```bash
ansible-playbook -i inventories/mon-site/hosts.yml playbooks/deploy.yml  --ask-vault-pass
ansible-playbook -i inventories/mon-site/hosts.yml playbooks/check.yml   --ask-vault-pass
ansible-playbook -i inventories/mon-site/hosts.yml playbooks/restart.yml --ask-vault-pass
ansible-playbook -i inventories/mon-site/hosts.yml playbooks/stop.yml    --ask-vault-pass
# ou : make deploy ARGS="-i inventories/mon-site/hosts.yml --ask-vault-pass"
```

Mise à jour : changez `grav_version` dans votre `group_vars`, rejouez `deploy.yml`.
Rollback : remettez la valeur antérieure, rejouez `deploy.yml` (voir "Rollback").

**Hors périmètre de l'usage autonome** : DNS, TLS, reverse proxy, pare-feu,
construction d'image, sauvegarde/restauration, orchestration multi-sites.

---

## Variables (interface publique du rôle)

Aucune variable ci-dessous n'impose de valeur métier. Toutes sont validées avant
exécution (`tasks/assert.yml`).

### Entrées principales

| Variable | Défaut | Description |
|---|---|---|
| `grav_image` | `""` (obligatoire) | Dépôt d'image, sans tag ni digest (ex. `ghcr.io/sepp67/projet-gites`) |
| `grav_version` | `""` (obligatoire) | Tag de version — jamais `"latest"` |
| `grav_container_name` | `grav-site` | Nom du conteneur/service — validé (`^[A-Za-z0-9][A-Za-z0-9._-]*$`, ni `..` `/` `:`) |
| `grav_bind_address` | *(aucun — obligatoire)* | Adresse d'écoute de l'hôte — voir "Contrat réseau" |
| `grav_http_port` | `8080` | Port hôte publié vers le port 80 du conteneur — validé (1–65535) |
| `grav_admin_user` / `grav_admin_password` / `grav_admin_email` | `""` | Bootstrap du premier compte — **les trois ou aucune** (voir "Contrat avec `grav-runtime`") |
| `grav_secrets` | `[]` | Fichiers secrets à monter en lecture seule (voir "Stratégie des secrets") |
| `grav_state` | `started` | `started` / `stopped` / `restarted` — validé |

### Réglages avancés (surchargeables, valeurs par défaut raisonnables)

| Variable | Défaut | Description |
|---|---|---|
| `grav_base_directory` | `/opt/grav-site/{{ grav_container_name }}` | Racine de l'instance sur l'hôte |
| `grav_restart_policy` | `unless-stopped` | Politique de redémarrage Docker |
| `grav_admin_fullname` / `_title` / `_language` | `""` | Optionnels, transmis au runtime |
| `grav_timezone` | `""` | `date.timezone` PHP |
| `grav_extra_environment` | `{}` | Variables d'environnement additionnelles, transmises telles quelles |
| `grav_healthcheck_interval` / `_timeout` / `_start_period` / `_retries` | `30s` / `3s` / `10s` / `3` | Miroir du `HEALTHCHECK` de l'image, ajustable sans reconstruire |
| `grav_deploy_wait_retries` / `_delay` | `30` / `2` | Attente côté Ansible du statut `healthy` |
| `grav_site_check_host` | `127.0.0.1` | Adresse de la vérification HTTP — **distincte** de `grav_bind_address` (qui peut valoir `0.0.0.0`, non joignable comme destination) |
| `grav_site_check_path` / `_status` | `/` / `200` | Page réelle vérifiée et code attendu |
| `grav_site_check_retries` / `_delay` / `_timeout` | `10` / `5` / `5` | Attente de la vérification HTTP |
| `grav_container_gid` | `82` | GID de `www-data` dans l'image (Alpine) — doit correspondre à l'image utilisée |
| `grav_manage_docker` | `true` | Installer Docker Engine + le plugin Compose (Debian/Ubuntu) |

### Valeurs dérivées de `grav_base_directory`

`grav_pages_directory`, `grav_accounts_directory`, `grav_data_directory`,
`grav_images_directory`, `grav_secret_directory`. Calculées par le rôle.
Leur surcharge directe est **dépréciée** (retrait éventuel en `v3`) — voir
[`docs/MIGRATION.md`](docs/MIGRATION.md).

### Variables d'environnement transmises au conteneur

`grav.env` (mode `0600`) ne contient que les variables du contrat `grav-runtime` :
`GRAV_ADMIN_USER` / `_PASSWORD` / `_EMAIL` (toutes ou aucune), `GRAV_ADMIN_FULLNAME`,
`_TITLE`, `_LANGUAGE`, `GRAV_TIMEZONE`, plus les clés de `grav_extra_environment`.
Format `raw` : aucune interpolation `${VAR}`, aucun dépouillement de guillemets.

### Stratégie des secrets

L'inventaire d'exemple applique une convention à sens unique :

1. `group_vars/grav_servers/vault.yml` (chiffré, jamais commité en clair) définit
   chaque secret sous un nom **préfixé `vault_`** (`vault_grav_admin_password`, …) —
   voir `vault.yml.example`.
2. `group_vars/grav_servers/main.yml` (non chiffré, versionné) affecte chaque variable
   attendue par le rôle à sa variable Vault : `grav_admin_password: "{{ vault_grav_admin_password }}"`.

Jamais l'inverse : `main.yml` ne contient que des références, jamais une valeur.

Pour les **fichiers secrets applicatifs** (`grav_secrets`), chaque entrée fournit
`name` et exactement l'un de `src` (fichier local) ou `content` (contenu inline) —
à chiffrer avec `ansible-vault`. Ils sont déposés en `0640 root:{{ grav_container_gid }}`
et montés individuellement en lecture seule sous `user/config/`.

### Créer et chiffrer le Vault

```bash
cp <votre-inventaire>/group_vars/grav_servers/vault.yml.example \
   <votre-inventaire>/group_vars/grav_servers/vault.yml
ansible-vault encrypt <votre-inventaire>/group_vars/grav_servers/vault.yml
```

---

## Contrat réseau

`grav_bind_address` est **obligatoire** (aucun défaut) : validé en forme avant
toute mutation (`tasks/assert.yml`). Trois usages :

```yaml
grav_bind_address: 127.0.0.1     # usage strictement local
grav_bind_address: 192.168.1.10  # VM accessible sur le LAN (cas normal)
grav_bind_address: 0.0.0.0       # toutes les interfaces, choix assumé
```

`127.0.0.1` ne convient pas si un reverse proxy tourne sur une autre VM : il
ne pourrait pas joindre l'instance — utilisez l'adresse LAN explicite.

| Élément | Responsable |
|---|---|
| Construction de la section Compose `ports:` | ce rôle |
| Valeur de l'adresse et du port | l'appelant (ce dépôt en autonome, `grav-sites-ops` en mode cible) |
| Domaine public, TLS, route Caddy | `control-repository`, indépendamment |
| Firewall et segmentation réseau | couche infrastructure, hors de ce rôle |

Le rôle ne configure pas le firewall : un accès direct à l'endpoint HTTP du
LAN contourne la terminaison TLS d'un éventuel reverse proxy.

`grav_site_check_host` (adresse du contrôle HTTP) reste, dans ce lot, une
variable indépendante à valeur par défaut `127.0.0.1` — sa dérivation
automatique depuis `grav_bind_address` arrive au Lot 5.

---

## Persistance

Le rôle monte 4 répertoires de l'hôte en bind mount, **indépendants du cycle de vie
du conteneur** :

| Répertoire hôte | Monté sur | Contenu |
|---|---|---|
| `grav_pages_directory` | `/var/www/html/user/pages` | Pages |
| `grav_accounts_directory` | `/var/www/html/user/accounts` | Comptes |
| `grav_data_directory` | `/var/www/html/user/data` | Données de plugins |
| `grav_images_directory` | `/var/www/html/user/images` | Médias |

Ces répertoires sont créés **sans mode ni propriétaire imposés** : `grav-runtime`
reprend lui-même leur propriété (`www-data`, uid/gid 82) au premier démarrage. Le rôle
ne réapplique jamais de mode ensuite. Ils **ne sont jamais recréés, vidés ni
resynchronisés** par un déploiement, une mise à jour, un redémarrage ou un rollback.

`grav-runtime` initialise un répertoire persistant depuis le contenu seedé dans l'image
**uniquement s'il est vide** au premier démarrage.

**Ne sont pas persistants** : `user/config`, `user/themes`, `user/plugins`. Ils sont
fournis par l'image applicative et changent par changement d'image. **Ne modifiez pas
la configuration, les thèmes ou les plugins depuis l'interface d'administration Grav** :
ces changements seraient perdus à la prochaine recréation du conteneur. Passez par le
dépôt applicatif, une nouvelle image et un nouveau tag.

## Rollback (manuel — n'est pas une restauration)

Un rollback est le **redéploiement explicite d'une référence d'image antérieure** :
remettre `grav_version` à sa valeur précédente et rejouer `deploy.yml`. Le rôle ne
compare pas la chronologie des versions ; il applique l'état demandé.

Le rôle garantit uniquement le retour de l'**image** et de sa configuration de
déploiement. **Il ne restaure aucune donnée.** Les volumes restent en l'état ; si la
version antérieure est incompatible avec des données écrites par la version plus
récente, le comportement n'est pas garanti. Une restauration complète (image +
configuration + sauvegarde des volumes) est une opération distincte, hors du rôle.

`{{ grav_base_directory }}/deployed_versions.log` conserve l'historique horodaté des
versions déployées (une ligne par changement réel).

## Contrat avec `grav-runtime`

Ce rôle s'appuie sur le contrat de `grav-runtime` sans le remettre en cause :

- Image applicative dérivée de `grav-runtime:<version>` par `FROM`, taguée explicitement.
- Port `80/tcp` HTTP uniquement — aucun TLS (reverse proxy externe, hors périmètre).
- `grav-runtime` **ne fournit aucun compte administrateur par défaut**. Il crée le
  premier compte **si et seulement si** `GRAV_ADMIN_USER` / `_PASSWORD` / `_EMAIL`
  sont toutes fournies **et** que le volume `accounts` est vide. Un état partiel
  (1 ou 2 sur 3) bloque le démarrage du conteneur.
- 4 répertoires persistants montables séparément (`user/pages`, `user/accounts`,
  `user/data`, `user/images`), initialisés par le runtime depuis son seed interne,
  par sous-répertoire, uniquement si vides.
- `HEALTHCHECK` Docker natif sur `GET /healthz` (technique, hors Grav).
- Redémarrage propre sur `SIGTERM`.

## Résolution du rôle

`playbooks/deploy.yml`, `check.yml`, `restart.yml`, `stop.yml` référencent le rôle par
**chemin relatif au playbook** (`{{ playbook_dir }}/..`), jamais par son nom. Ce dépôt
*est* le rôle (`tasks/`, `defaults/`, `templates/`, `meta/` à sa racine) ; `playbooks/`
est un niveau en dessous, donc `{{ playbook_dir }}/..` désigne toujours la racine du
dépôt, **quel que soit le nom du dossier de clonage**. `ansible.cfg` définit
`roles_path` uniquement pour un éventuel rôle tiers ajouté via `requirements.yml` ; il
n'intervient jamais dans la résolution de *ce* rôle. Les fichiers de `tests/` utilisent
la même résolution par chemin relatif.

## Préflight

Avant un premier déploiement, `make preflight ARGS="-i <inv> [--ask-vault-pass]"`
vérifie, sans rien modifier :

| Point | Vérification |
|---|---|
| Version d'Ansible | `ansible --version` |
| Collection `community.docker` | `ansible-galaxy collection list community.docker` |
| Connectivité SSH | `ansible grav_servers -m ping` |
| `become` fonctionnel | `ansible grav_servers -b -m command -a "whoami"` |
| Architecture de la cible | `ansible grav_servers -m setup -a "filter=ansible_architecture"` |
| Registre GHCR joignable | `ansible grav_servers -m uri -a "url=https://ghcr.io/v2/ status_code=200,401"` |
| Fichier Vault présent | `test -f <VAULT>` |

Aucune de ces vérifications ne duplique ce que le rôle valide déjà à l'exécution
(`tasks/assert.yml`, `tasks/verify_docker.yml`).

## Makefile

Point d'entrée optionnel, sans logique propre — chaque cible appelle Ansible
directement. Ce dépôt ne ciblant aucune VM par défaut, `deploy` / `check` / `stop` /
`restart` échouent tant qu'un inventaire n'est pas fourni via `ARGS` :

```bash
make deploy  ARGS="-i inventories/mon-site/hosts.yml --ask-vault-pass"
make lint
make vault-edit VAULT=inventories/mon-site/group_vars/grav_servers/vault.yml
```

## Structure des dossiers déployés sur l'hôte

```text
{{ grav_base_directory }}/
├── docker-compose.yml       # généré, générique — ne pas éditer à la main
├── grav.env                 # généré, mode 0600
├── secrets/                 # fichiers secrets, montés en lecture seule
├── data/{pages,accounts,data,images}/   # bind mounts persistants
├── .deployed_version        # image:version actuellement déployée
└── deployed_versions.log    # historique horodaté
```

## Tests

```bash
ansible-lint . playbooks/ inventories/ examples/
cd tests
ansible-playbook -i inventory test.yml
ansible-playbook -i inventory test_env_encoding.yml
ansible-playbook -i inventory test_standalone.yml
```

- `tests/test.yml` : premier déploiement, redéploiement idempotent, mise à jour et
  rollback avec deux versions publiques réelles de `grav-runtime`, en vérifiant à
  chaque étape l'image en exécution, la survie d'un marqueur dans `user/pages` et le
  nombre de lignes de `deployed_versions.log`.
- `tests/test_env_encoding.yml` : un mot de passe admin contenant `$ # " ' \` et des
  espaces ressort **strictement identique** dans le conteneur (comparaison masquée).
- `tests/test_standalone.yml` : exécute réellement les playbooks de `playbooks/` en
  sous-processus, depuis un inventaire de test localhost.

`grav_manage_docker: false` dans les trois — l'installation de Docker
(`tasks/docker.yml`) est validée séparément (voir `docs/MIGRATION.md`, refonte `v2`).

Vérifications statiques (CI, sans Docker) : `ansible-lint`, `--syntax-check` des
playbooks, validité de l'inventaire d'exemple, garde-fous (`grav_version` jamais
`latest`, aucun `vault.yml` réel commité, aucun lien symbolique hors dépôt, aucune
adresse de VM privée, aucune référence au `control-repository` ni à un chemin local).

## Limitations connues

- Installation de Docker limitée à Debian/Ubuntu.
- Pas d'authentification registre (`docker login`) — l'image doit être publique.
- Un digest immuable n'est pas encore supporté (prévu en `v2.0.0`).

## Licence

MIT
