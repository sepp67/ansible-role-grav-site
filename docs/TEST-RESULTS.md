# Résultats des tests T01–T23

Ce document consigne l'état de couverture des 23 scénarios normatifs du contrat
(§17). Il est mis à jour à chaque lot.

Les lignes « EXÉCUTÉ LOCALEMENT » ont été jouées avec la commande indiquée sur
cette machine ; les jobs CI exécutent la **commande équivalente**. La ligne
T04–T08 porte le résultat du **run GitHub Actions du Lot 9** (branche
`refonte/lot-9-release-preparation`) — voir la section « Exécution GitHub
Actions (Lot 9) » en fin de document.

## Statuts

| Statut | Sens |
|---|---|
| `COMPLIANT` | exécuté et vert (localement ou en CI) |
| `PARTIALLY COMPLIANT` | partiellement couvert / à confirmer sur un autre environnement |
| `TEST GAP` | non exécuté, ou couverture indirecte seulement |

## Matrice

| Test | Sujet | Statut | Preuve / commande |
|---|---|---|---|
| T01 | validation des variables avant mutation | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `ansible-playbook tests/test_assertions.yml` (46 scénarios, `changed=0`) |
| T02 | installation de Docker (Debian/Ubuntu) | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s install` (Debian 12, Ubuntu 22.04, Ubuntu 24.04) |
| T03 | idempotence de l'installation | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule idempotence -s install`, `changed=0` sur les 3 plateformes |
| T04 | premier déploiement : compte créé, 4 volumes initialisés | `COMPLIANT` | JOB CI `test` sur `ubuntu-24.04` / Docker `overlay2` — run `105e085` (`ansible-playbook test.yml`, `failed=0`). Également EXÉCUTÉ LOCALEMENT sur `overlayfs` (`ok=260`). Voir « Exécution GitHub Actions (Lot 9) » |
| T05 | second passage idempotent : aucun marqueur modifié, compte inchangé, journal stable | `COMPLIANT` | idem T04 — `deployed_versions.log` reste à 1 ligne |
| T06 | mise à jour A→B (`1.0.3`→`1.0.4`) : conteneur sur B, 4 marqueurs + compte conservés | `COMPLIANT` | idem T04 — journal +1 ligne |
| T07 | rollback B→A (`1.0.4`→`1.0.3`) : conteneur sur A, 4 marqueurs + compte conservés | `COMPLIANT` | idem T04 — journal +1 ligne |
| T08 | persistance de `pages` / `accounts` / `data` / `images` sur toutes les phases | `COMPLIANT` | `tests/_verify_phase.yml` : marqueur distinct par volume relu aux 4 phases + nombre de fichiers de comptes et checksum de `<user>.yaml` stables (le seed de B n'écrase rien) |
| T09 | bootstrap avec 3 identifiants → fichier de compte réel | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s deploy` (compte créé, mot de passe restitué masqué) |
| T10 | accounts vide sans identifiants → échec avant `docker_compose_v2` | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s deploy` (aucun compose/env/conteneur) |
| T11 | compte existant → redéploiement sans `grav_admin_*`, non recréé | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s deploy` (nombre, sha1, inode, mtime inchangés) |
| T12/T13 | `grav_bind_address` : 127.0.0.1 / IPv4 LAN / 0.0.0.0 | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s deploy` (ports rendus + HTTP ; IPv4 LAN = IP du bac à sable) |
| T14 | recreate / pas de fausse mutation | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s digest` T20 état 2/3 (passages sans recreate) |
| T15 | verdict `starting → healthy` / `unhealthy → échec immédiat` | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s deploy` (unhealthy → échec < 120 s) |
| T16 | `.last_failure.log` 0600 root, sortie sans secret, cycle de vie | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s deploy` (sortie sous-processus capturée) |
| T17 | redémarrage avec image présente, registre jamais consulté | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s pull` (référence locale non résolvable + `docker events` sans `pull`) |
| T18 | `grav_force_pull: true` → `pull: always` → tentative réelle | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s pull` (registre dispo → pull ; indispo → échec attribuable au pull) |
| T19 | déploiement par digest, référence effective valide | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s digest` (5 preuves : compose, `.Config.Image`, `.Image`, `RepoDigests`, pas de pseudo-référence) |
| T20 | traçabilité structurée (5 champs, journal append-only, bump de version derrière le même digest) | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `tests/test_traceability.yml` (exhaustif, hors Docker) + `molecule test -s digest` T20 états 1–5 (Docker réel) |
| T21 | deux instances sur le même hôte, sans collision | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `molecule test -s multi_instance` (2 `include_role` dans un même play ; conteneurs, projets, ports, volumes, comptes, état, marqueurs distincts ; redéploiement de A sans effet de bord sur B) |
| T22 | consommation via `requirements.yml`, appel par nom installé | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `ansible-playbook tests/test_consume_via_requirements.yml` (`git+file://@SHA` → `sepp67.grav_site`) |
| T23 | rôle joué avec `gather_facts: false`, traçabilité renseignée | `COMPLIANT` | EXÉCUTÉ LOCALEMENT — `tests/test_traceability.yml` (`gather_facts: false`) + `molecule test -s digest` (converge entier sans facts, `deployed_at` renseigné) |

## Limites de couverture résiduelles

- **T13b « IPv4 LAN »** : testé sur l'IP du conteneur de bac à sable
  (`172.17.0.x`), pas sur une IPv4 de réseau physique.
- **T15n** : verdict `unhealthy` provoqué avec `nginx:alpine` (image sans
  `/healthcheck.sh`), pas avec une instance Grav réellement dégradée.
- **Molecule multi-distribution** pour `deploy` / `digest` / `pull` /
  `multi_instance` : Debian 12 uniquement (logique du rôle OS-indépendante après
  installation de Docker ; `install` est matricé).
- **Nested Docker `overlay2`** : indisponible sur la workstation (`vfs` imposé).

## Environnement d'exécution locale

- Molecule 25.12.0 / ansible-core 2.17.14 (venv jetable) ; driver `docker`,
  conteneurs privilégiés + systemd.
- Docker-in-Docker `storage-driver: vfs` (l'overlayfs imbriqué n'est pas
  supporté) ; cgroup v2.
- Images de plateforme épinglées par digest d'index OCI — voir `molecule/README.md`.

## Exécution GitHub Actions (Lot 9)

Branche `refonte/lot-9-release-preparation`, événement `push`.

### Run fonctionnel observé — SHA `105e085`

- Run : <https://github.com/sepp67/ansible-role-grav-site/actions/runs/33789033957>
  (`run_number` 13, `run_attempt` 1, `event: push`).
- Runner : `ubuntu-24.04` (Ubuntu 24.04.4 LTS, noyau `6.17.0-1022-azure`).
- Docker du runner : **Docker Engine 28.0.4**, **`Storage Driver: overlay2`**,
  `Cgroup Driver: systemd` ; Docker Compose `v2.38.2`. Le job `test` a exécuté
  `docker version` / `docker compose version` / `docker info`, extrait le driver
  (`overlay2`), et l'a accepté avant de lancer T04–T08.

| Job | Conclusion |
|---|---|
| `lint` | `success` |
| `static-checks` | `success` |
| `test` (T04–T08 + encodage + couche autonome) | `success` |
| `molecule-install` (T02/T03, 3 plateformes) | `success` |
| `molecule-deploy` (T09–T16) | `success` |
| `molecule-pull` (T17/T18) | `success` |
| `molecule-digest` (T19/T20/T23) | `success` |
| `molecule-multi-instance` (T21) | `success` |

Aucun job `skipped`, `cancelled` ou `continue-on-error`.

Détail du job `test` (SHA `105e085`) :

| Playbook | PLAY RECAP |
|---|---|
| `test.yml` (T04–T08) | `ok=258 changed=22 failed=0` — 4 phases, image en exécution vérifiée à chaque phase, **4 marqueurs de volume intacts** (initial / idempotent / A→B / B→A), nombre de fichiers de comptes et checksum de `testadmin.yaml` stables, journal `1 → 1 → 2 → 3` lignes |
| `test_env_encoding.yml` | `ok=54 failed=0` |
| `test_standalone.yml` | `ok=13 failed=0` |

Les seuls `fatal:` du run sont des **cas négatifs attendus**, capturés par `rescue` :
`molecule-deploy` T10 (la garde administrateur bloque un déploiement sans compte ni
identifiants) et T15 (`nginx:alpine` sans `/healthcheck.sh` → échec `unhealthy`
immédiat). Les PLAY RECAP de `converge` / `verify` de tous les scénarios Molecule
affichent `failed=0` et la séquence se termine par `Pruning` (destroy inclus).

### Run final du HEAD définitif

_(à compléter — run sur le HEAD portant ce commit ; aucun commit après ce run.)_
