# Matrice de conformité `REQ-*` — cible `2.0.0`

Source normative : `contrat-architectural-ansible-role-grav-site.md` v1.0.1.
État de référence : branche de préparation `2.0.0` (Lots 0 → 9).

Cette matrice est l'aboutissement du préflight de conformité initial : chaque
exigence y est ramenée à son **statut final** après les neuf lots, avec le
fichier, le test ou le job CI qui en fait la preuve.

## Statuts

| Statut | Sens |
|---|---|
| `CONFORME` | exigence satisfaite, preuve dans le code et/ou un test exécuté |
| `CONFORME (périmètre 2.0.0)` | satisfaite dans les limites explicitement documentées de `2.0.0` |
| `NON APPLICABLE` | hors périmètre de la refonte atomique (décision de contrat) |

## Synthèse

| Statut | Nombre |
|---|---|
| `CONFORME` | 60 |
| `CONFORME (périmètre 2.0.0)` | 1 (REQ-017 — IPv6 hors périmètre) |
| `NON APPLICABLE` | 2 (REQ-039b collection, REQ-052 exposition publique) |

Aucune exigence ne reste `NON-COMPLIANT`, `NOT IMPLEMENTED`, `PARTIALLY
COMPLIANT`, `DOCUMENTATION ONLY` ou `TEST GAP`.

---

## 5.1 Responsabilité atomique et séparation rôle / exploitation

| ID | Exigence | Statut | Preuve |
|---|---|---|---|
| REQ-001 | §3.1 / INV-01 — une instance par invocation | `CONFORME` | `tasks/main.yml`, `tasks/deploy.yml` (`project_src` unique) ; T21 (`molecule/multi_instance`) |
| REQ-002 | §3.1 — séquence des étapes ordonnée, validation avant mutation | `CONFORME` | `tasks/main.yml` (`assert` → `admin_guard` → docker → répertoires → secrets → deploy → healthcheck → verify_admin → version) ; T01 |
| REQ-003 | §3.2 — aucun profil réel de site/VM dans le dépôt | `CONFORME` | `inventories/example/` fictif (RFC 5737) ; `inventories/production/` retiré du suivi (Lot 0–2) ; garde-fou CI RFC 1918 |
| REQ-004 | §3.2 — aucune mutation VM par défaut | `CONFORME` | `ansible.cfg` sans `inventory =` ; `Makefile` exige `ARGS="-i …"` ; `assert.yml` échoue proprement sur un clone frais |
| REQ-005 | §3.2 — harnais autonome générique + inventaire d'exemple fictif | `CONFORME` | `inventories/example/**`, `examples/**` ; job CI `static-checks` (`ansible-inventory`, garde-fous) |
| REQ-006 | §3.1 / §3.2 — usage autonome pour un site unique | `CONFORME` | `playbooks/*.yml` (résolution par chemin relatif) ; `tests/test_standalone.yml` (job CI `test`) |
| REQ-007 | §3.3 — hors périmètre respecté | `CONFORME` | aucune tâche parc/image/proxy/DNS/sync/backup ; garde-fou CI `control[_-]repo` |
| REQ-049 | §16 D1 — profils réels déplacés, harnais générique conservé | `CONFORME` | idem REQ-003/004 ; `docs/MIGRATION.md` §1 |

## 5.2 Images, versions, digest

| ID | Exigence | Statut | Preuve |
|---|---|---|---|
| REQ-009 | INV-03 — `latest` interdit | `CONFORME` | `tasks/assert.yml` (`grav_version != 'latest'`) ; T01 ; garde-fou CI |
| REQ-010 | INV-04 / §5.5 — tag non présenté comme immuable ; digest = garantie | `CONFORME` | `grav_digest` ajouté (Lot 4) ; README « Référence d'image effective » ; T19 |
| REQ-011 | §5.1-5.2 — trois champs `grav_image` / `grav_version` / `grav_digest` | `CONFORME` | `defaults/main.yml` ; `tasks/assert.yml` (forme du digest) ; T01, T19 |
| REQ-012 | §5.3 — référence effective `image:version` **ou** `image@digest`, jamais l'hybride | `CONFORME` | `vars/main.yml` (`_grav_effective_reference`), `templates/docker-compose.yml.j2` ; T19 (5 preuves) |
| REQ-013 | §5.4 — `grav_image` refuse tag/digest incorporé, autorise le port de registre | `CONFORME` | `tasks/assert.yml` ; T01 (`tests/test_assertions.yml`, cas `registry:5000/img`) |
| REQ-014 | §5.6 / D4 — `pull: missing` par défaut + `grav_force_pull` | `CONFORME` | `tasks/deploy.yml`, `defaults/main.yml` ; T17/T18 (`molecule/pull`) |
| REQ-015 | §11.3 — un redémarrage ne dépend pas du registre | `CONFORME` | conséquence de REQ-014 ; T17 (`docker events` sans `pull`) |

## 5.3 Contrat réseau

| ID | Exigence | Statut | Preuve |
|---|---|---|---|
| REQ-016 | §6.1 / §7.1 / D7 — `grav_bind_address` obligatoire, sans défaut | `CONFORME` | `defaults/main.yml` (aucun défaut), `tasks/assert.yml` ; T01 ; T12/T13 (`molecule/deploy`) |
| REQ-017 | §7.2 — valeurs autorisées ; refus chaîne vide et noms d'hôte | `CONFORME (périmètre 2.0.0)` | `tasks/assert.yml` : IPv4 littérale stricte + `0.0.0.0` pleinement validées, hostname refusé. **IPv6 explicitement hors périmètre `2.0.0`** (refusée avec message), documentée `docs/MIGRATION.md` §2 et README « Contrat réseau » |
| REQ-018 | §7.4 — contrôle HTTP sur une adresse dérivée de `grav_bind_address` | `CONFORME` | `vars/main.yml` (`_grav_site_check_host`), `tasks/healthcheck.yml` ; T13 |
| REQ-019 | §7.4 — adresse de contrôle surchargeable | `CONFORME` | `grav_site_check_host` (public, `defaults/`) ; README |
| REQ-020 | §7.5 — pas de firewall ; doc du contournement TLS | `CONFORME` | aucune tâche firewall ; README « Contrat réseau » (accès direct LAN contourne TLS) |
| REQ-053 | §7.3 — la section Compose `ports:` appartient au rôle | `CONFORME` | `templates/docker-compose.yml.j2` ; T12/T13 |

## 5.4 Persistance

| ID | Exigence | Statut | Preuve |
|---|---|---|---|
| REQ-021 | §8.1 — 4 volumes montés (`pages`, `accounts`, `data`, `images`) | `CONFORME` | `templates/docker-compose.yml.j2`, `defaults/main.yml` ; **T08** (job CI `test`, marqueur distinct par volume) |
| REQ-022 | §8.2 — non-écrasement (pas de purge/`--delete`/restauration au rollback) | `CONFORME` | `tasks/directories.yml` (aucun `mode` réappliqué) ; `tests/test_persistence_untouched.yml` ; **T06/T07/T08** |
| REQ-023 | §8.3 — initialisation ignorée si le répertoire n'est pas vide | `CONFORME` | délégué à `grav-runtime` `seed-init.sh` ; **T08** (checksum de `<user>.yaml` stable A→B→A) |
| REQ-024 | §8.5 / D6 — le rôle ne choisit pas de direction de synchronisation | `CONFORME` | aucune tâche de sync ; README « Persistance » |
| REQ-056 | §8.1 / INV-05 — `user/images` distinct de `user/data` | `CONFORME` | `templates/docker-compose.yml.j2` (montages séparés) ; T08 |
| REQ-008 | INV-07 / §6.3 — chemins dérivés calculés par le rôle | `CONFORME` | `vars/main.yml` (calcul), surcharge honorée avec avertissement `[DEPRECATED]` ; T01 ; `docs/MIGRATION.md` §5 |
| REQ-008b | INV-07 / §8.4 / D11 — `config`+`themes`+`plugins`+version runtime = image | `CONFORME` | `user/config` non monté ; README « Persistance » (ce qui n'est pas persistant) |
| REQ-051 | §8.4 — mises à jour plugins/thèmes via l'admin déconseillées | `CONFORME` | README « Persistance » (consigne opérateur explicite) |

## 5.5 Identifiants administrateur et secrets

| ID | Exigence | Statut | Preuve |
|---|---|---|---|
| REQ-025 | §9.1 / §9.2 / D8 — les identifiants de l'appelant sont les seuls actifs | `CONFORME` | `templates/grav.env.j2` ; `grav-runtime` ne fournit aucune valeur ; T09 (`molecule/deploy`) |
| REQ-026 | §9.3 / D8 — pas de retour silencieux à un état non protégé | `CONFORME` | `tasks/admin_guard.yml` + `tasks/verify_admin_account.yml` (Lot 6) ; `tests/test_admin_guard.yml` (T09/T10/T11, 20 scénarios) |
| REQ-020a | §9.3 — comportement « volume `accounts` vide » explicite/documenté/testé | `CONFORME` | garde avant mutation (échec bloquant) ; `docs/MIGRATION.md` §6 ; README « Contrat administrateur » |
| REQ-027 | §9.4 — `grav.env` : `root:root`, `0600`, `no_log`, pas de fuite | `CONFORME` | `tasks/deploy.yml` (`mode 0600`, `no_log`) ; `rescue` sous `no_log` + `.last_failure.log` `0600` ; `tests/test_no_secret_leak.yml` (job CI) |
| REQ-028 | §9.5 — fichiers secrets applicatifs (XOR, RO, `no_log`) | `CONFORME` | `tasks/secrets.yml` (XOR, anti-traversée, `0640`, `no_log`) ; T16 |
| REQ-055 | §9.4 — valeurs de bootstrap absentes des fichiers de traçabilité | `CONFORME` | `tasks/version.yml` (jamais de `GRAV_ADMIN_*`) ; `tests/test_no_secret_leak.yml` ; T08 (état structuré sans mot de passe) |

## 5.6 Docker, santé, idempotence, facts

| ID | Exigence | Statut | Preuve |
|---|---|---|---|
| REQ-029 | §10.1 / D2 — `grav_manage_docker: true` par défaut ; `false` vérifie et échoue proprement | `CONFORME` | `defaults/main.yml`, `tasks/docker.yml`, `tasks/verify_docker.yml` ; T02/T03 (`molecule/install`) |
| REQ-030 | §10.2 — chemin `grav_manage_docker: true` couvert par des tests | `CONFORME` | `molecule/install` (3 plateformes) + `molecule idempotence` ; job CI `molecule-install` |
| REQ-031 | §10.3 — doc/métadonnées énumèrent distributions/versions/architectures | `CONFORME` | `meta/main.yml` (Debian 12, Ubuntu 22.04/24.04), README « Systèmes supportés » alignés sur `tasks/docker.yml` |
| REQ-032 | §11.1 — sémantique de chaque état documentée | `CONFORME` | README « Ce que fait le rôle » + « Contrat administrateur » (tableau par `grav_state`) |
| REQ-033 | §11.4 — fenêtre d'attente cohérente ; pas d'échec pendant `starting` | `CONFORME` | `tasks/healthcheck.yml` (sortie sur verdict définitif), plancher `120 s` dans `assert.yml` ; T15 |
| REQ-034 | §11.5 — diagnostic d'échec utile sans exposer de secret | `CONFORME` | `rescue` : `no_log` + `.last_failure.log` `0600 root` + message générique ; T16 ; `tests/test_failure_log_lifecycle.yml` |
| REQ-035 | §11.6 — la traçabilité ne doit pas échouer sous `gather_facts: false` | `CONFORME` | `tasks/version.yml` (`now(utc=true)`) ; T23 (`tests/test_traceability.yml` + `molecule/digest` sans facts) |
| REQ-050 | INV-10 / §3.1.9 — contrôle santé à deux niveaux | `CONFORME` | `tasks/healthcheck.yml` (verdict Docker puis HTTP réel) ; T13/T15 |
| REQ-046 | §6.2 — réglages avancés restés dans `defaults/` | `CONFORME` | `vars/main.yml` ne porte que les valeurs **dérivées** ; réglages avancés dans `defaults/main.yml` |
| REQ-044 | §6.4 — variables temporaires préfixées `_grav_` | `CONFORME` | `set_fact` et `register` internes préfixés (`_grav_*`) après Lot 8 ; `ansible-lint` |
| REQ-045 | §6.5 — clés de `grav_extra_environment` validées | `CONFORME` | `tasks/assert.yml` (`^GRAV_[A-Z0-9_]+$` + liste réservée) ; T01 |
| REQ-054 | §11.1 — états `started` / `stopped` / `restarted` gérés | `CONFORME` | `tasks/assert.yml`, `tasks/deploy.yml`, `tasks/main.yml` ; T04–T07 |

## 5.7 Traçabilité, rollback, consommation, indépendance

| ID | Exigence | Statut | Preuve |
|---|---|---|---|
| REQ-036 | INV-11 / §13.1 — état durable structuré (5 champs) | `CONFORME` | `templates/deployed_state.yml.j2` (`image`, `declared_version`, `digest`, `effective_reference`, `deployed_at`) ; T20 |
| REQ-037 | §13.2 — `effective_reference` toujours valide ; label + digest jamais concaténés | `CONFORME` | `vars/main.yml` (même logique que le compose) ; T19/T20 |
| REQ-037b | §3.1 — validation des paramètres avant toute mutation | `CONFORME` | `tasks/main.yml` (`assert.yml` en premier) ; T01 |
| REQ-038 | §13.3 — journal append-only : une entrée seulement si l'état contractuel change | `CONFORME` | `tasks/version.yml` (clé = `declared_version` + `digest` + référence effective) ; T05/T07/T20 ; **T05** (aucune ligne sur un passage identique) |
| REQ-039 | §13.4 — sorties de diagnostic ≠ interface persistante inter-dépôts | `CONFORME` | aucun `set_stats` ; garde-fou CI |
| REQ-040 | §12.1-12.3 — rollback = redéploiement explicite ; volumes en place ; healthcheck rejoué | `CONFORME` | `tasks/version.yml`, `tasks/main.yml` ; **T07** (`molecule` + job CI `test`) |
| REQ-041 | §12.2 / §12.5 — le rollback n'est pas présenté comme une restauration | `CONFORME` | README « Rollback (manuel — n'est pas une restauration) » |
| REQ-042 | §14.1-14.2 / D10 — consommable via `requirements.yml` ; aucun chemin absolu / lien symbolique | `CONFORME` | lien symbolique retiré (Lot 0) ; `.gitignore` ; garde-fou CI symlink ; **T22** (`tests/test_consume_via_requirements.yml`, `git+file://@SHA` → `sepp67.grav_site`) |
| REQ-043 | §2.4 / §3.3 — aucune dépendance avec `grav-sites-ops` / `control-repository` | `CONFORME` | garde-fou CI ; README « chaîne de dépendance » |
| REQ-052 | §2.3 — le passage à l'exposition publique n'impose pas un redéploiement | `NON APPLICABLE` | le rôle ne connaît pas la publication (couche `control-repository`) |

## 5.8 Documentation, versionnement, tests

| ID | Exigence | Statut | Preuve |
|---|---|---|---|
| REQ-047 | §15.3 — toute rupture inventoriée, changelog, guide de migration, version majeure | `CONFORME` | `CHANGELOG.md` (`[2.0.0]`, découpage normalisé) ; `docs/MIGRATION.md` (tableau des ruptures + §1–§13) |
| REQ-026b | §11.2 / §17 — README, exemples et changelog reflètent le comportement réel | `CONFORME` | README réécrit (Lots 1–2, finalisé Lot 9) ; garde-fou CI « renvois voir README » |
| REQ-048 | §17 — les 23 scénarios T01–T23 réellement exécutés et consignés | `CONFORME` | `docs/TEST-RESULTS.md` ; T01–T03, T09–T23 exécutés (local + jobs CI Molecule) ; **T04–T08 exécutés par le job CI `test` sur `overlay2` (Lot 9)** |
| REQ-039b | §20 — transformation en collection Ansible | `NON APPLICABLE` | décision explicitement reportée par le contrat (§20) |

---

## Limites résiduelles (documentées, assumées pour `2.0.0`)

1. **IPv6 hors périmètre** (REQ-017) — `grav_bind_address` n'accepte que l'IPv4
   littérale et `0.0.0.0`. Contournement : lier en IPv4, terminer l'IPv6 au
   reverse proxy. Réexamen possible en `2.1.0` avec `ansible.utils` + `netaddr`.
2. **Installation de Docker : Debian / Ubuntu uniquement** — les autres OS
   exigent `grav_manage_docker: false`.
3. **Pas d'authentification de registre** — l'image applicative doit être
   publique (pas de `docker login`).
4. **Couverture multi-distribution des scénarios Molecule fonctionnels**
   (`deploy` / `digest` / `pull` / `multi_instance`) : Debian 12 uniquement
   (logique du rôle OS-indépendante après installation de Docker ; `install`
   est matricé sur les 3 plateformes).
5. **T13 « IPv4 LAN »** exercé sur l'IP du conteneur de bac à sable, pas sur une
   IPv4 de réseau physique.
6. **Collection Ansible** (REQ-039b) — non traitée, reportée par le contrat.
