# Point d'entrée ergonomique : chaque cible appelle directement Ansible ou
# les outils standards, sans logique cachée ni paramètre masqué — voir
# README.md "Utilisation autonome du dépôt". Ce Makefile ne réimplémente
# rien du rôle ni des playbooks.
#
# Ce dépôt ne cible AUCUNE VM par défaut : les cibles deploy/check/stop/
# restart échouent tant qu'un inventaire n'est pas fourni via ARGS.
#   make deploy ARGS="-i inventories/votre-site/hosts.yml"
#   make deploy ARGS="-i inventories/votre-site/hosts.yml --check --diff"

.PHONY: dependencies lint preflight check deploy stop restart vault-edit vault-view

ARGS ?=

dependencies:
	ansible-galaxy collection install -r requirements.yml

lint:
	# playbooks/ et inventories/ passés explicitement : ansible-lint ne les
	# découvre pas automatiquement dans un dépôt qui EST un rôle (constaté en
	# test — tasks/ et tests/ sont, eux, découverts par défaut).
	ansible-lint . playbooks/ inventories/

# Vérifications préalables non destructives (voir README.md "Préflight") :
# connectivité SSH, become, architecture, registre GHCR depuis la cible, et
# présence du fichier Vault attendu. Ne duplique aucune validation déjà
# faite par le rôle (Docker/Compose : voir tasks/verify_docker.yml).
preflight:
	ansible --version
	ansible-galaxy collection list community.docker
	ansible grav_servers -m ping $(ARGS)
	ansible grav_servers -b -m command -a "whoami" $(ARGS)
	ansible grav_servers -m setup -a "filter=ansible_architecture" $(ARGS)
	ansible grav_servers -m uri -a "url=https://ghcr.io/v2/ status_code=200,401" $(ARGS)
	@test -f inventories/production/group_vars/grav_servers/vault.yml || \
		(echo "Absent : inventories/production/group_vars/grav_servers/vault.yml — voir README 'Créer et chiffrer le Vault'." && exit 1)

check:
	ansible-playbook playbooks/check.yml $(ARGS)

deploy:
	ansible-playbook playbooks/deploy.yml $(ARGS)

stop:
	ansible-playbook playbooks/stop.yml $(ARGS)

restart:
	ansible-playbook playbooks/restart.yml $(ARGS)

vault-edit:
	ansible-vault edit inventories/production/group_vars/grav_servers/vault.yml

vault-view:
	ansible-vault view inventories/production/group_vars/grav_servers/vault.yml
