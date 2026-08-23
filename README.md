# ansible-role-grav-site

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Ansible](https://img.shields.io/badge/Ansible-2.17-red)](https://docs.ansible.com/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue)](https://docs.docker.com/compose/)

**Reusable Ansible role for deploying, updating and rolling back persistent Grav CMS instances from versioned application images.**

The role consumes an application image derived from `grav-runtime` and manages its
operational lifecycle on a target host.

It does not build or modify the application itself.

## Where does it fit?

```text
grav-runtime
      │
      ▼
application image
(projet-gites,
 projet-lavallee, ...)
      │
      ▼
ansible-role-grav-site       ← YOU ARE HERE
      │
      ▼
persistent Grav instance
```

The role separates deployment mechanics from application content. A compatible
application can therefore be deployed by changing its image and version without
duplicating deployment logic.

## Responsibilities

### What it does

- Installs Docker Engine and Docker Compose when requested.
- Creates the instance directories on the target host.
- Provisions persistent Grav directories.
- Generates the Docker Compose configuration.
- Injects configuration and secrets.
- Pulls and starts an explicitly versioned application image.
- Waits for the Docker health check.
- Verifies that a real application page responds.
- Records deployed versions.
- Supports updates by changing the requested version.
- Supports manual rollback through the same deployment mechanism.

### What it does not do

- Does not build Docker images.
- Does not modify application images.
- Does not contain website themes, plugins or content.
- Does not manage application source code.
- Does not manage DNS.
- Does not manage TLS certificates.
- Does not manage the reverse proxy.
- Does not configure a firewall or VPN.
- Does not perform automatic rollback.
- Does not currently authenticate against private container registries.

These boundaries are intentional: the role manages one Grav application's deployment
lifecycle, not the surrounding infrastructure.

## Quick Start

### Requirements

- Ansible Core `>= 2.17, < 2.18`
- `community.docker >= 5.0.0, < 6.0.0`
- Debian or Ubuntu target when Docker installation is managed by the role
- Docker Engine + Docker Compose v2

Install the required Ansible collection:

```bash
ansible-galaxy collection install -r requirements.yml
```

Use the role from a playbook:

```yaml
- hosts: grav_servers
  become: true

  roles:
    - role: ansible-role-grav-site
      vars:
        grav_image: "ghcr.io/sepp67/projet-gites"
        grav_version: "1.0.0"
```

Run the deployment:

```bash
ansible-playbook deploy.yml
```

To update the application, change:

```yaml
grav_version: "1.0.1"
```

and run the same deployment again.

To roll back, restore the previous explicit version and run the same deployment.

Persistent application data is kept outside the container lifecycle.

## Tested & Supported

| Component | Support |
|---|---|
| Ansible Core | `>= 2.17, < 2.18` |
| `community.docker` | `>= 5.0.0, < 6.0.0` |
| Managed target OS | Debian / Ubuntu |
| Managed architectures | x86_64 / aarch64 |
| Container runtime | Docker Engine |
| Compose | Docker Compose v2 |
| Application images | Images derived from `grav-runtime` |
| Registry | Public container registry / GHCR |

Run static checks:

```bash
make lint
```

Run the integration tests:

```bash
cd tests

ansible-playbook -i inventory test.yml
ansible-playbook -i inventory test_env_encoding.yml
ansible-playbook -i inventory test_standalone.yml
```

The test suite covers:

- initial deployment;
- idempotent redeployment;
- version update;
- manual rollback;
- persistent-data survival;
- environment-variable encoding;
- standalone deployment workflows.

Production deployments must always use an explicit application version. `latest` is
not accepted as a deployment version.

## Documentation & Related Components

Full documentation:

**https://docs.lavallee.tech/grav-stack/deployment/**

Related repositories:

- [`grav-runtime`](https://github.com/sepp67/grav-runtime) — shared runtime and persistence contract.
- [`projet-gites`](https://github.com/sepp67/projet-gites) — Grav application deployed by this role.
- [`projet-lavallee-website`](https://github.com/sepp67/projet-lavallee-website) — second application using the same architecture.

## License

MIT