# Environnement de développement — Grav

Document technique consignant l'installation Grav réalisée pour TASK-001-01-01 (FEAT-001-01, EPIC-001). Conforme à DR-007 (choix de Grav CMS), DR-008 (architecture monolithique) et DR-009 (backend intégré à Grav).

## VM de développement

| Élément | Valeur |
|---|---|
| Adresse | `192.168.1.89` |
| Hostname | `vm-gites` |
| OS | Debian 12 (bookworm) |
| Accès | SSH, utilisateur `devops` (clé publique) |

## Runtime PHP

| Élément | Valeur |
|---|---|
| Version installée | PHP 8.2.32 (paquet Debian `php8.2-cli`) |
| Extensions installées | `curl`, `mbstring`, `gd`, `xml` (dom, simplexml, xmlreader, xmlwriter, xsl), `zip`, `opcache` |
| Outil complémentaire | `unzip` (extraction des archives Grav) |

## Installation Grav

| Élément | Valeur |
|---|---|
| Version installée | **Grav 1.7.53.2** |
| Source | Package officiel `grav-v1.7.53.2.zip`, dépôt GitHub [`getgrav/grav`](https://github.com/getgrav/grav/releases/tag/1.7.53.2) |
| Type de package | Core (sans plugin Admin ni thème additionnel) |
| Chemin d'installation | `/home/devops/grav` |
| PHP minimum requis (Grav) | 7.3.6 (`GRAV_PHP_MIN` dans `system/defines.php`) |

### Écart par rapport à la version cible initiale

La dernière version stable de Grav (2.0.11) exige PHP ≥ 8.3, indisponible dans les dépôts officiels Debian 12 (bookworm fournit PHP 8.2, pas de backports configurés). Après validation humaine, la branche **1.7.x** (dernière version : 1.7.53.2), pleinement compatible avec PHP 8.2, a été retenue à la place. Aucun dépôt tiers n'a été ajouté au système.

Cette décision devra être prise en compte lors de :
- **TASK-001-01-02** (vérification de la configuration PHP requise),
- **TASK-001-01-03** (installation en production via Ansible) — le même couple PHP 8.2 / Grav 1.7.53.2 devra être répliqué, sauf nouvelle décision explicite.

### Vérification effectuée

Le serveur de développement intégré de PHP (`php -S 127.0.0.1:8000 system/router.php`) sert correctement la page d'accueil par défaut de Grav (HTTP 200, `<title>Home | Grav</title>`). Aucun processus serveur n'est laissé actif en permanence ; la configuration Nginx/PHP-FPM pour un service persistant relève de FEAT-001-05.

## Vérification de la configuration PHP (TASK-001-01-02)

Vérification des prérequis PHP de Grav 1.7.53.2, tels que déclarés dans le `composer.json` du package installé, comparés à la configuration active de `devops@192.168.1.89` (`/etc/php/8.2/cli/php.ini`).

### Version

| Prérequis Grav | Version installée | Conformité |
|---|---|---|
| `^7.3.6 \|\| ^8.0` | PHP 8.2.32 | Conforme |

### Extensions requises

| Extension | Contrainte | Statut |
|---|---|---|
| `json` | `*` | Présente |
| `openssl` | `*` | Présente |
| `curl` | `*` | Présente |
| `zip` | `*` | Présente |
| `dom` | `*` | Présente |
| `libxml` | `*` | Présente |
| `gd` | `*` | Présente |
| `mbstring` (polyfill Symfony si absente) | — | Présente nativement |

### Directives `php.ini`

| Directive | Valeur actuelle | Attendu par Grav | Conformité |
|---|---|---|---|
| `memory_limit` | `-1` (illimité) | ≥ 128M | Conforme |
| `max_execution_time` | `0` (illimité) | ≥ 60s | Conforme |
| `date.timezone` | `UTC` | non vide | Conforme |
| `opcache.enable` | `1` | activé recommandé | Conforme |
| `allow_url_fopen` | `1` | activé recommandé | Conforme |

### Résultat

Aucun écart constaté. La configuration PHP actuelle satisfait intégralement les prérequis documentés de Grav 1.7.53.2. Aucune modification de `php.ini` n'a été nécessaire.

**Hors périmètre** (non requis par Grav lui-même, à traiter lors de tâches ultérieures si besoin) : `upload_max_filesize` (2M) et `post_max_size` (8M) restent aux valeurs par défaut de Debian ; leur dimensionnement pour la galerie photographique relève de FEAT-002-04. La configuration PHP-FPM/Nginx pour la production relève de FEAT-001-05.
