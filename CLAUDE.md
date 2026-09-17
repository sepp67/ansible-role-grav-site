# Instructions locales — ansible-role-grav-site

Avant toute action, lire le fichier `../CLAUDE.md`.

Ce dépôt fournit le mécanisme Ansible atomique de déploiement d'une instance
Grav.

## Invariants locaux

- traiter une seule instance Grav par invocation ;
- conserver l'idempotence ;
- utiliser les modules Ansible plutôt que des commandes shell lorsque cela est
  possible ;
- protéger avec `no_log: true` toute tâche susceptible de manipuler un secret ;
- ne jamais journaliser une valeur sensible ;
- ne jamais orchestrer plusieurs sites ni embarquer un inventaire de
  production ;
- ne pas réimplémenter les fonctions de `grav-runtime` ;
- préserver les données persistantes existantes lors d'un redéploiement ;
- valider les variables structurantes avant toute mutation ;
- déployer uniquement une référence d'image explicite reçue en paramètre ;
- ne jamais utiliser une étiquette flottante telle que `latest`.

La configuration multi-instance, les versions par site et les secrets
opérateur appartiennent à `grav-sites-ops`.

## Avant une modification

Consulter au minimum :

- `README.md` ;
- `defaults/` ;
- `tasks/` ;
- `templates/` ;
- `docs/` ;
- les scénarios et contrôles automatisés présents dans le dépôt.

## Contrôles spécifiques

- validation des variables et préflight avant mutation ;
- premier déploiement ;
- second passage idempotent ;
- mise à jour vers une autre référence d'image ;
- rollback lorsque le changement le permet ;
- healthcheck et vérifications post-déploiement ;
- traçabilité de la référence déclarée et effectivement déployée ;
- absence de fuite de secrets dans les sorties.

