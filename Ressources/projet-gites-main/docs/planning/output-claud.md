PRE-APP-001 — Analyse de l'environnement de développement Grav
Avant de répondre aux 5 points, un constat factuel bloquant que je ne peux pas laisser de côté :

⚠️ Le README.md réel du dépôt ne correspond pas au contenu que vous avez collé dans votre message précédent
Le fichier README.md que je viens de lire sur disque contient un tout autre document : il décrit un projet nommé « grav-docs » — « Image Docker pour Grav CMS (Core + Admin) […] utilisée comme documentation interne » —, avec des domaines docs.lavallee.local / docs.lavallee.tech, un déploiement géré par un dépôt tiers devops_staging_prod_infra, et une image publiée sur ghcr.io/sepp67/grav-docs:latest.

C'est exactement la même image tierce (ghcr.io/sepp67/grav-docs) que j'avais trouvée tournant dans un conteneur Docker sur la VM en tout début de session, et que vous aviez supprimée car non conforme au projet gîtes. Elle réapparaît maintenant comme code source, non commité, directement dans ce dépôt (Dockerfile, docker-compose.yml, docker/*, grav/user/**, README.md, LICENSE — tous en Untracked dans git status, aucun lien avec le commit 92c937b du projet gîtes).

Rien dans ces fichiers ne mentionne les gîtes, Alsace/Vosges, le calendrier de disponibilités, etc. — le contenu est générique et cohérent avec un tout autre produit (« grav-docs »).

Je n'ai pas de moyen de déterminer si :

vous avez importé intentionnellement cet outil Docker pour servir de « rôle Grav générique » local (mentionné dans votre README « Mission »), et le texte du README.md lui-même reste simplement à corriger/adapter plus tard, ou
il s'agit d'une contamination accidentelle entre deux dépôts locaux différents.
Je continue l'analyse factuelle ci-dessous, mais ne valide pas PRE-APP-001 tant que ce point n'est pas clarifié, car la réponse aux 5 questions dépend de la réponse.

1. État réel du dépôt

projet-gites/
├── CLAUDE.md
├── README.md                  ← contenu "grav-docs" (voir ci-dessus)
├── LICENSE                    ← MIT, Sébastien Clem, 2026
├── Dockerfile                 ← build Grav Core+Admin dans un conteneur (non commité)
├── docker-compose.yml         ← lancement local (non commité)
├── docker/
│   ├── entrypoint.sh          ← init volume + bootstrap admin + démarre php-fpm/nginx
│   ├── bootstrap-admin.sh     ← création optionnelle d'un compte admin via bin/plugin login
│   ├── nginx.conf
│   └── php-fpm.conf
├── grav/
│   └── user/                  ← squelette VIDE (uniquement des .gitkeep)
│       ├── config/.gitkeep
│       ├── pages/.gitkeep
│       ├── plugins/.gitkeep
│       └── themes/.gitkeep
└── docs/                      ← documentation projet gîtes (contexte, DR, plan, etc.)
git status : tous les fichiers Docker/grav//README.md/LICENSE sont non suivis (untracked) — rien de tout cela n'a jamais été commité dans projet-gites.

2. Instance Grav ou rôle Ansible ?
Ni l'un ni l'autre au sens strict. Il n'y a pas de rôle Ansible dans ce dépôt (aucun fichier trouvé). Il n'y a pas non plus d'instance Grav versionnée : le vrai code de Grav (Core + Admin) est téléchargé à la construction de l'image Docker (curl .../grav-admin/latest dans le Dockerfile), donc jamais commité dans ce dépôt. Ce qui existe réellement ici, c'est une définition d'image Docker qui construit et lance Grav dans un conteneur, plus un squelette de dossiers vides.

3. Méthode de test locale disponible

docker compose build
docker compose up -d
→ Site sur http://localhost:8080, Admin sur http://localhost:8080/admin.

C'est la seule méthode disponible. Mais elle a une limite structurelle importante pour du développement de contenu (cf. point 4).

4. Code applicatif vs déploiement — et un problème de conception à signaler
Déploiement/infra (présents mais hors périmètre applicatif défini par votre README « Mission ») : Dockerfile, docker-compose.yml, docker/entrypoint.sh, docker/bootstrap-admin.sh, docker/nginx.conf, docker/php-fpm.conf.
Applicatif potentiel : grav/user/** — mais entièrement vide à ce jour (uniquement des .gitkeep). Aucun thème, aucune page, aucun plugin custom n'existe encore dans le dépôt.
Problème structurel constaté (docker/entrypoint.sh, lignes 54-58) : le contenu de grav/user/ du dépôt n'est copié dans le volume Docker qu'au tout premier démarrage du conteneur (if [ ! -f .../user/.initialized ]). Une fois ce marqueur posé, plus aucune resynchronisation n'a lieu — le volume Docker devient la seule source de vérité, indépendante du dépôt Git. Ce mécanisme est adapté à un déploiement figé (bootstrap unique d'un site de documentation), mais pas à un flux de développement itératif où l'on modifierait grav/user/pages/, themes/, etc. dans le dépôt et attendrait de voir le résultat — les modifications ne seraient jamais reprises sans intervention manuelle (suppression du volume, ou montage différent).

5. Molecule / mécanisme de test
Aucun. Pas de Molecule, pas de suite de tests automatisés, pas de CI locale. Le README mentionne un workflow .github/workflows/publish-ghcr.yml qui n'existe pas dans ce dépôt — confirmation supplémentaire que ces fichiers proviennent d'un autre dépôt.

Éléments manquants
Clarification sur l'origine et le rôle voulu des fichiers Docker/grav//README.md (voir alerte en tête).
Un mécanisme de synchronisation dépôt ↔ volume Docker adapté au développement itératif (bind mount plutôt que volume nommé + copie unique), si ce Docker doit servir d'environnement de dev.
Une instance Grav réellement démarrable pour tester (aucune n'existe actuellement, ni dans le dépôt ni confirmée en cours d'exécution).
Un README.md cohérent avec le projet gîtes.
Recommandation (strictement limitée au développement/test local)
Je ne peux pas recommander une méthode définitive tant que l'origine des fichiers Docker n'est pas clarifiée. Sous réserve de cette clarification, si ces fichiers sont bien destinés à servir d'environnement de dev local pour ce projet, la seule adaptation minimale nécessaire serait de remplacer le volume nommé grav_user par un bind mount vers ./grav/user dans docker-compose.yml, afin que les fichiers créés dans le dépôt (pages, thèmes, plugins) soient immédiatement reflétés dans le conteneur sans dépendre du mécanisme .initialized. Je n'effectue aucune modification sans votre confirmation.

Question bloquante avant de valider PRE-APP-001 : ces fichiers Docker/grav//README.md sont-ils bien destinés à ce projet (gîtes), à corriger et adapter, ou proviennent-ils d'une confusion avec un autre dépôt local (« grav-docs ») ?
