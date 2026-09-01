# Guide de migration

## `1.x` → `2.0.0` (en préparation)

`2.0.0` sera une **version majeure** : elle introduit des changements d'interface
incompatibles, tous annoncés ici. Aucune rupture n'est introduite silencieusement.

Ce document est mis à jour au fil de la refonte. Tant que `2.0.0` n'est pas publiée,
épinglez la version `1.0.1` :

```yaml
# requirements.yml
roles:
  - name: grav_site
    src: git+https://github.com/sepp67/ansible-role-grav-site.git
    version: "v1.0.1"
```

### Résumé des ruptures d'interface `2.0.0`

| # | Rupture | Lot | Action minimale |
|---|---|---|---|
| §2 | `grav_bind_address` **obligatoire** (plus de défaut) + **IPv4 uniquement** (IPv6 refusée) | 3, 5 (appliqué) | Ajouter `grav_bind_address` (IPv4 littérale) à votre profil |
| §7 | `grav_image` : tag ou digest incorporé **refusé** | 3 (appliqué) | Déplacer le tag vers `grav_version` |
| §9 | `grav_extra_environment` : **clés validées** (`^GRAV_[A-Z0-9_]+$`, pas de clé réservée) | 3 (appliqué) | Renommer/retirer les clés non conformes |
| §3 | Politique de pull : `always` → `missing` | 4 (appliqué) | `grav_force_pull: true` pour retrouver l'ancien comportement |
| §2 | `grav_site_check_host` : défaut `127.0.0.1` → **dérivé** de `grav_bind_address` | 5 (appliqué) | Retirer une surcharge redondante ; sinon aucune action |

Les dépréciations (§5, sans échec) et les ajouts (§4 `grav_digest`, §8 `grav_admin_type`)
ne sont pas des ruptures.

---

## 1. Retrait de `inventories/production/` (déjà effectif sur `main`)

Le dépôt du rôle ne contient plus de profil d'exploitation réel. L'ancien
`inventories/production/` (spécifique à `projet-gites`) a été supprimé du suivi Git.

### Si vous déployiez `projet-gites` depuis un clone de ce dépôt

Votre profil et votre secret vivent maintenant **dans votre propre dépôt**
(un fork d'exploitation, ou le futur `grav-sites-ops`). Procédure, à faire une fois :

1. **Récupérez votre profil.** L'ancien
   `inventories/production/group_vars/grav_servers/main.yml` contenait :

   ```yaml
   grav_image: "ghcr.io/sepp67/projet-gites"
   grav_version: "1.0.7"                     # la version réellement déployée
   grav_container_name: "projet-gites"
   grav_base_directory: "/opt/projet-gites"
   grav_bind_address: "0.0.0.0"              # -> à remplacer par l'IP LAN de la VM (voir §2)
   grav_http_port: 8080
   grav_admin_user:     "{{ vault_grav_admin_user }}"
   grav_admin_password: "{{ vault_grav_admin_password }}"
   grav_admin_email:    "{{ vault_grav_admin_email }}"
   grav_admin_fullname: "{{ vault_grav_admin_fullname }}"
   grav_admin_title:    "{{ vault_grav_admin_title }}"
   grav_admin_language: "{{ vault_grav_admin_language }}"
   # grav_secrets:
   #   - name: email-private.php
   #     content: "{{ vault_grav_email_private_php }}"
   ```

   Transposez ces valeurs dans les `host_vars` de votre dépôt d'orchestration :

   ```text
   votre-depot-ops/
   ├── requirements.yml                    # grav_site @ git tag vX.Y.Z
   ├── inventories/grav-vms/
   │   ├── hosts.yml                       # gites-prod  ansible_host: 192.168.1.10 (IP LAN réelle)
   │   ├── host_vars/gites-prod.yml        # <- contenu ci-dessus, sans les secrets
   │   └── host_vars/gites-prod.vault.yml  # <- vos secrets (voir 2)
   └── playbooks/site.yml
   ```

2. **Relocalisez votre Vault.** Le fichier chiffré
   `inventories/production/group_vars/grav_servers/vault.yml` de votre copie de travail
   **n'a jamais été suivi par Git** (il est exclu par `.gitignore`). Il est toujours
   présent sur votre disque. Déplacez-le dans votre dépôt d'orchestration :

   ```bash
   mv inventories/production/group_vars/grav_servers/vault.yml \
      ../votre-depot-ops/inventories/grav-vms/host_vars/gites-prod.vault.yml
   ```

   Il reste chiffré ; sa clé Vault ne change pas.

3. **Supprimez le répertoire devenu orphelin** de votre copie de travail :

   ```bash
   rm -rf inventories/production
   ```

Le rôle lui-même est inchangé : votre `playbooks/site.yml` d'orchestration l'invoque
exactement comme avant (`roles: [grav_site]` ou `include_role`).

### Si vous utilisiez le dépôt comme rôle réutilisable

Aucune action. Le rôle (`defaults/`, `tasks/`, `templates/`, `meta/`) est inchangé.

### Nouvel usage autonome (un seul site)

```bash
cp -r inventories/example inventories/mon-site
# éditez inventories/mon-site/… puis créez le Vault
ansible-playbook -i inventories/mon-site/hosts.yml playbooks/deploy.yml --ask-vault-pass
```

---

## 2. `grav_bind_address` : obligatoire (Lot 3) + IPv4 uniquement (Lot 5) — appliqué

Avant : `grav_bind_address` avait un défaut de `127.0.0.1`.

Depuis le Lot 3 : **aucun défaut**. Vous devez fournir explicitement l'adresse d'écoute :

| Contexte | Valeur |
|---|---|
| Développement / usage strictement local | `127.0.0.1` |
| VM du réseau local (cas normal) | l'IP LAN de la VM, ex. `192.168.1.10` |
| Toutes les interfaces (choix assumé) | `0.0.0.0` |

`127.0.0.1` **ne convient pas** si un reverse proxy (Caddy) tourne sur une autre VM :
il ne pourrait pas joindre l'instance. Utilisez l'IP LAN explicite.

### Lot 5 : validation IPv4 stricte, IPv6 refusée

`tasks/assert.yml` valide désormais `grav_bind_address` **avant toute mutation** :

- **IPv4 littérale stricte** — chaque octet 0–255, sans zéro initial (`01.2.3.4`
  refusé), exactement 4 octets (`1.2.3` et `1.2.3.4.5` refusés) ;
- ou la valeur spéciale `0.0.0.0` ;
- un **nom d'hôte** est refusé (le rôle n'assume aucune résolution DNS) ;
- **toute IPv6 est refusée**, y compris `::`, `::1`, `2001:db8::1` — une chaîne
  contenant `:` n'est jamais considérée comme une adresse valide.

Le pré-contrôle permissif du Lot 3 (« toute chaîne contenant `:` est acceptée comme
IPv6 ») est **supprimé**. Une validation IPv6 fiable exigerait `ansible.utils` +
`netaddr` : dépendances jugées disproportionnées pour ce rôle. `REQ-017` reste donc
**partiellement conforme** — IPv4 pleinement validé, IPv6 explicitement hors périmètre
`2.0.0` et documenté ici.

**Si vous aviez besoin d'IPv6** : liez l'instance à une adresse IPv4 et laissez le
reverse proxy en amont terminer l'IPv6. Le rôle ne gère de toute façon ni TLS ni
reverse proxy.

### Lot 5 : `grav_site_check_host` dérivé de `grav_bind_address`

`grav_site_check_host` passe d'un défaut `127.0.0.1` à **vide** : l'adresse du
contrôle HTTP applicatif est désormais **dérivée** de `grav_bind_address` —

| `grav_bind_address` | `grav_site_check_host` effectif |
|---|---|
| adresse précise (`127.0.0.1`, IP LAN…) | la même adresse |
| `0.0.0.0` | `127.0.0.1` |

Un override explicite reste possible (`grav_site_check_host: "…"`) mais ne doit pas
contenir `:` (ni IPv6, ni port).

**Action** : si vous surchargiez `grav_site_check_host` avec la **même** valeur que
`grav_bind_address` (ou `127.0.0.1` en face d'un bind `0.0.0.0`), retirez la
surcharge — la dérivation produit le même résultat. Conservez-la uniquement si le
contrôle doit viser une adresse différente de l'adresse d'écoute.

**Action** : ajoutez `grav_bind_address` (adresse IPv4 littérale ou `0.0.0.0`) à votre
profil avant de passer en `2.0.0`.

---

## 3. Politique de pull : `missing` par défaut (Lot 4 — appliqué) — **changement de comportement**

Avant : `pull: always` à chaque déploiement `started`.

Depuis ce lot : `pull: missing`. Un redémarrage ne dépend plus de la disponibilité du
registre si l'image (tag **ou digest**) est déjà présente localement. Pour forcer une
récupération : `grav_force_pull: true` (→ `pull: always`).

**Action** : si vous comptiez sur `deploy` pour tirer une nouvelle image sans changer
`grav_version` (tag mobile), ce ne sera plus le cas — épinglez une version explicite
ou passez `grav_force_pull: true`.

---

## 4. `grav_digest` (Lot 4 — appliqué)

Nouvelle variable **optionnelle** (additive, pas une rupture) pour un épinglage
immuable :

```yaml
grav_image: ghcr.io/sepp67/projet-gites
grav_version: "1.0.7"                     # reste obligatoire (label lisible)
grav_digest: "sha256:0123…ef"            # optionnel, fortement recommandé pour une VM durable
```

Validation : `""` ou `sha256:` suivi de 64 caractères hexadécimaux **minuscules**.

Référence Docker effective : `grav_image:grav_version` sans digest,
`grav_image@grav_digest` avec. **Jamais** `image:version@digest`.

**Action** : aucune si vous ne l'utilisez pas. Pour épingler, ajoutez `grav_digest`
à votre profil (le digest est visible via `docker buildx imagetools inspect` ou
`docker inspect` de l'image, ou dans la sortie de `docker push`).

---

## 5. Chemins dérivés : dépréciation (Lot 3 — appliqué)

`grav_pages_directory`, `grav_accounts_directory`, `grav_data_directory`,
`grav_images_directory`, `grav_secret_directory` restent acceptés et **honorés tels
quels** en `2.0.0`. Une surcharge dont la valeur diffère du chemin normalement dérivé
de `grav_base_directory` émet désormais un avertissement `[DEPRECATED]` — le chemin
dérivé normal, lui, n'émet rien. Retrait éventuel en `3.0.0`, précédé d'une évaluation
d'un besoin légitime de répartition multi-disques (contrat v1.0.1 §6.3).

**Action** : ne les surchargez plus ; définissez uniquement `grav_base_directory`. Si
vous avez un besoin réel de répartir un répertoire sur un disque distinct, gardez la
surcharge (elle reste fonctionnelle) et signalez ce besoin — une interface générique
pourra être ajoutée avant tout retrait en `3.0.0`.

---

## 6. Garde contre une instance non initialisée (Lot 6 — appliqué)

`grav-runtime` ne fournit **aucun** compte ni identifiant administrateur. Sans garde,
une instance dont le volume `accounts` est vide démarre **non initialisée** : la
création interactive du premier compte est accessible depuis `/admin`.

### Garde avant toute mutation (`tasks/admin_guard.yml`) — appliquée

Le rôle constate la **présence d'un fichier de compte persistant** — au moins un
`*.yaml` ou `*.yml` dans `grav_accounts_directory` (le bind mount de `user/accounts`
sur l'hôte). Il ne lit **jamais** le contenu de ces fichiers et ne juge ni leur
syntaxe ni leur validité fonctionnelle : « un fichier de compte est présent », ou non.

| Fichier de compte persistant | `grav_admin_*` | `grav_state` | Résultat |
|---|---|---|---|
| présent | absentes | `started` / `restarted` | autorisé |
| présent | les trois | `started` / `restarted` | autorisé, compte non recréé |
| absent | les trois | `started` / `restarted` | bootstrap autorisé |
| absent | **aucune** | `started` / `restarted` | **échec, avant mutation** |
| absent ou présent | **partielles** | tout état | **échec** (règle « les trois ou aucune ») |
| absent | aucune | `stopped` | autorisé (aucun bootstrap imposé) |

L'échec intervient **avant** l'installation de Docker, la création des répertoires et
le rendu de `grav.env` (`tasks/main.yml` : `admin_guard` juste après `assert`).

### Vérification après démarrage (`tasks/verify_admin_account.yml`) — appliquée

Après le healthcheck et **avant** l'enregistrement de la traçabilité (`version.yml`),
le rôle vérifie **à nouveau** qu'au moins un fichier `*.yaml` / `*.yml` existe dans
`grav_accounts_directory`. Sinon :

- le déploiement **échoue** (message d'erreur **sans secret**) ;
- `version.yml` n'est pas exécuté → **aucune** nouvelle entrée de traçabilité ;
- le déploiement n'est **pas** présenté comme réussi.

Sautée pour `grav_state: stopped`. Couvre : un bootstrap silencieusement raté, un
volume `accounts` perdu depuis la garde pré-mutation, des identifiants mal transmis.

**Action** : gardez `grav_admin_user` / `grav_admin_password` / `grav_admin_email`
dans votre Vault, **y compris après le premier déploiement** — ils redeviennent
obligatoires si le volume `accounts` est perdu ou recréé vide.

---

## 7. Validation de `grav_image` durcie (Lot 3 — appliqué)

Avant : seule `grav_image | length > 0` était vérifiée.

Depuis ce lot : `grav_image` ne doit contenir **ni tag final, ni digest incorporé**.
Un port de registre reste explicitement autorisé.

| Exemple | Statut |
|---|---|
| `ghcr.io/sepp67/projet-gites` | valide |
| `registry.example.net:5000/projet-grav` | valide (port de registre) |
| `ghcr.io/sepp67/projet-gites:1.0.7` | **refusé** — utilisez `grav_version` |
| `ghcr.io/sepp67/projet-gites@sha256:…` | **refusé** — utilisez `grav_digest` (Lot 4) |

**Action** : si `grav_image` contenait un tag ou un digest, déplacez-le vers
`grav_version` (ou attendez `grav_digest` au Lot 4).

---

## 8. `grav_admin_type` (Lot 3 — appliqué)

Nouvelle variable optionnelle, **additive** : `""` (défaut, le runtime choisit `both`),
`"admin"`, `"api"` ou `"both"`. Aucune action requise si vous ne l'utilisiez pas déjà
via `grav_extra_environment` (auquel cas, migrez vers `grav_admin_type`, plus lisible
et désormais validée).

---

## 9. `grav_extra_environment` : clés validées (Lot 3 — appliqué) — **RUPTURE `2.0.0`**

Avant : seules les valeurs étaient contrôlées (interdiction des retours à la ligne) ;
n'importe quelle clé était acceptée.

Depuis ce lot : les **clés** sont validées — motif `^GRAV_[A-Z0-9_]+$`, et une clé ne
peut plus écraser une variable déjà gérée explicitement par le rôle (`GRAV_ADMIN_USER`,
`_PASSWORD`, `_EMAIL`, `_FULLNAME`, `_TITLE`, `_LANGUAGE`, `_TYPE`, `GRAV_TIMEZONE` —
la liste complète des clés que le rôle émet lui-même dans `grav.env`).

C'est un **changement d'interface incompatible** : une configuration utilisant une clé
en minuscules, sans préfixe `GRAV_`, ou l'une des clés réservées, **échouera désormais
à la validation, avant toute mutation**.

**Action** : renommez la clé (préfixe `GRAV_`, majuscules), ou — si elle correspond à
une variable de première classe (`grav_admin_type`, `grav_timezone`, `grav_admin_*`) —
utilisez cette variable directement.

---

## 10. Traçabilité structurée (Lot 4 — appliqué)

Nouveau fichier `{{ grav_base_directory }}/.deployed_state.yml` sur l'hôte :

```yaml
image: "ghcr.io/sepp67/projet-gites"
declared_version: "1.0.7"
digest: "sha256:…"                # "" si non épinglé
effective_reference: "ghcr.io/sepp67/projet-gites@sha256:…"
deployed_at: "2026-09-01T12:00:00Z"
```

Changements sur les fichiers existants :

| Fichier | Avant | Après |
|---|---|---|
| `.deployed_version` | `image:version` | référence effective (= `image:version` sans digest — **identique** ; `image@digest` avec) |
| `deployed_versions.log` | `<iso8601> image:version` | `<horodatage> <declared_version> <référence effective>` — **une colonne `declared_version` en plus** ; +1 ligne quand l'**état contractuel** change (`declared_version`, `digest`, ou référence effective) |

Une **nouvelle version derrière un digest identique** (ex. `1.0.7` → `1.0.8`, même
`sha256`) : la référence Docker effective ne change pas, mais `.deployed_state.yml`
actualise `declared_version` **et** le journal gagne une ligne (l'état contractuel a
changé).

L'historique existant du journal **n'est jamais supprimé** (les anciennes lignes
gardent leur format `<iso8601> image:version`). L'horodatage vient désormais de
`now(utc=true)` (heure du contrôleur) — la traçabilité fonctionne même si l'appelant
utilise `gather_facts: false`.

**Action** : aucune. Si un script lisait `.deployed_version` en supposant le format
`image:version`, il fonctionne toujours tant qu'aucun digest n'est utilisé ; sinon,
lisez plutôt `.deployed_state.yml` (`effective_reference` ou `declared_version`).

---

## 11. Fenêtre d'attente du healthcheck et logs d'échec (Lot 5 — appliqué)

### Sémantique exacte de l'attente (`tasks/healthcheck.yml`)

| État renvoyé par Docker | Comportement du rôle |
|---|---|
| `starting` | le rôle **continue d'attendre** (nouvelle interrogation toutes les `grav_deploy_wait_delay` s) |
| `healthy` | **succès** immédiat de l'étape ; on passe à la vérification HTTP |
| `unhealthy` | **échec immédiat** (`rescue`) — pas de nouvelle tentative |

La fenêtre `grav_deploy_wait_retries × grav_deploy_wait_delay` (défaut `60 × 5 =
300 s`) borne uniquement la phase `starting`. **Ce n'est pas une période de
récupération** : dès que Docker rend le verdict `unhealthy`, le rôle échoue sans
attendre la fin de la fenêtre. Un `unhealthy` n'est jamais « re-tenté » jusqu'à
`healthy`.

La boucle sort donc soit sur un verdict définitif (`healthy`/`unhealthy`), soit sur
l'épuisement de la fenêtre alors que Docker répond encore `starting` (démarrage
anormalement long → échec via `rescue`).

### Nouveaux défauts

`grav_deploy_wait_retries` : `30` → `60` ; `grav_deploy_wait_delay` : `2` → `5`
(fenêtre `300 s`). `tasks/assert.yml` refuse désormais une fenêtre
`retries × delay < 120 s` (plancher explicite ; `120 s` couvre le pire cas
`start_period` + `interval` × `retries` du healthcheck par défaut ≈ `100 s`).

### Logs d'échec — `{{ grav_base_directory }}/.last_failure.log`

**Sur échec** : le `rescue` n'imprime plus les logs du conteneur dans la sortie
Ansible (`no_log`). Les 200 dernières lignes sont écrites — fichier **créé ou
remplacé** — dans `{{ grav_base_directory }}/.last_failure.log`, `mode 0600`,
`root:root`, sur l'hôte cible ; le message d'erreur renvoie vers ce fichier.

**Sur succès** : `tasks/clear_failure_diagnostic.yml` **supprime** un
`.last_failure.log` laissé par un échec antérieur, dès que le healthcheck repasse au
vert. Idempotent ; ne lit jamais le fichier ; ne touche jamais un répertoire
persistant (`pages`, `accounts`, `data`, `images`). Un `grav_state: stopped`
(healthcheck non joué) ne déclenche ni écriture ni suppression.

**Action** : si vous aviez réduit `grav_deploy_wait_retries` / `_delay` sous le seuil
de `120 s` combiné, remontez-les (ou acceptez le nouveau défaut). Le rôle nettoie
lui-même `.last_failure.log` au retour au vert ; une purge manuelle reste possible.
