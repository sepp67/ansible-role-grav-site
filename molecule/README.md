# Scénarios Molecule

Couverture Docker réelle du rôle. Nécessite `../requirements-test.txt` dans un
venv (voir l'en-tête de ce fichier). Conteneurs **privilégiés + systemd**,
Docker-in-Docker (`storage-driver: vfs` — l'overlayfs imbriqué n'est pas
supporté).

| Scénario | Tests (§17 du contrat) |
|---|---|
| `install` | T02, T03 — installation de Docker + idempotence, 3 plateformes |
| `deploy` | T09–T16 — bootstrap admin, `admin_guard`, `grav_bind_address`, verdict de santé, `.last_failure.log` |
| `pull` | T17, T18 — politique de pull `missing` / `always` |

```bash
molecule test -s install
molecule test -s deploy
molecule test -s pull
```

## Images de base épinglées par digest

Les images de plateforme sont épinglées par **digest d'index OCI**
(`application/vnd.oci.image.index.v1+json`) : Docker résout le manifeste
`linux/amd64` ou `linux/arm64` — l'épinglage reste **compatible multi-architecture**.

| Image | Digest complet | Résolu le |
|---|---|---|
| `geerlingguy/docker-debian12-ansible` | `sha256:a906d69671f93666731d196add52a2447966303d8bc398da8fd01bdb543909dc` | 2026-09-03 |
| `geerlingguy/docker-ubuntu2204-ansible` | `sha256:9dea87fba8ef05c32a68d03443f171362c191b528e277a01a28cb1c1d7c20b8c` | 2026-09-03 |
| `geerlingguy/docker-ubuntu2404-ansible` | `sha256:625d7dfdad134fd25c28873a8b8b81c4907ecb57c66f20e9b599582ef376b46c` | 2026-09-03 |

### Procédure de mise à jour volontaire

Ne mettre à jour un digest que **délibérément** (nouvelle version de l'image de
base, correctif de sécurité) :

```bash
docker buildx imagetools inspect geerlingguy/docker-debian12-ansible:latest
#   -> relever la ligne « Digest: sha256:… » (celle de l'INDEX, MediaType
#      application/vnd.oci.image.index.v1+json), PAS un manifeste de plateforme
```

1. Remplacer le digest dans le `molecule.yml` concerné et ce tableau (+ la date).
2. Rejouer `molecule test -s <scénario>` pour chaque scénario touché.
3. Committer séparément (`test: mettre à jour le digest de l'image Molecule <image>`).

## `grav-runtime` (image applicative de test)

`molecule/deploy` et `molecule/pull` tirent `ghcr.io/sepp67/grav-runtime:1.0.4`
par **tag** (image publique du dépôt applicatif, pas une image de plateforme).
`molecule/digest` lit son digest réel à l'exécution (`docker inspect
--format '{{index .RepoDigests 0}}'`) pour exercer `grav_digest`.
