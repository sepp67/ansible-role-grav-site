# examples/

Exemples **non opérationnels** de consommation externe du rôle (mode cible — voir
`../README.md`, « Utilisation comme rôle réutilisable »).

| Fichier | Rôle |
|---|---|
| `requirements.yml` | Installe le rôle depuis un tag Git publié (nom installé : `grav_site`) + la collection `community.docker`. |
| `site.yml.example` | Playbook d'un dépôt d'orchestration qui invoque `grav_site` par son nom installé, avec des valeurs propres au site. Renommer en `site.yml` dans le dépôt appelant. |

```bash
ansible-galaxy install -r examples/requirements.yml
ansible-playbook -i <votre-inventaire> examples/site.yml.example --ask-vault-pass
```

L'inventaire, les `host_vars`/`group_vars` propres au site et à la VM, et les secrets
(Vault) appartiennent au dépôt appelant — **jamais à ce dépôt**. Le rôle ne dépend pas
de l'arborescence interne du dépôt appelant, et réciproquement.

Pour un usage **autonome** (déployer un seul site depuis un clone de ce dépôt),
n'utilisez pas `examples/` : copiez `../inventories/example/` et utilisez
`../playbooks/`.
