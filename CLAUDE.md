
### `ansible-role-grav-site/CLAUDE.md`

```markdown
# Instructions locales — ansible-role-grav-site

Lire d’abord le fichier `../CLAUDE.md`.

Ce dépôt fournit un rôle Ansible générique.

Principes :

- utiliser les modules Ansible plutôt que des commandes shell lorsque possible ;
- conserver l’idempotence ;
- utiliser `no_log: true` pour les tâches manipulant des secrets ;
- exiger des tags d’image explicites ;
- ne jamais utiliser `latest` par défaut ;
- ne jamais modifier les données persistantes existantes ;
- valider toutes les variables structurantes avec `assert`;
- tester un premier déploiement, un second passage idempotent et une mise à jour.

Le rôle orchestre le runtime mais ne doit pas réimplémenter ses fonctions.