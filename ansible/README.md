# Ansible — configuration management & deployment

Automates EC2 host configuration (Docker install) and product-service deployment.
Originally the Week 12 / Week 10-lab Ansible work, reorganised into the standard
`playbooks/ roles/ inventory/` layout.

> Run all commands from **this `ansible/` directory** so `ansible.cfg` is picked
> up automatically (it points the inventory at `inventory/inventory.ini` and
> `roles_path` at `roles/`).

## Layout

```
ansible/
├── ansible.cfg                         # inventory + roles_path defaults, host_key_checking off
├── inventory/
│   ├── inventory.ini                   # static inventory (EDIT IPs)
│   └── inventory_aws_ec2.yml           # AWS EC2 dynamic inventory plugin
├── playbooks/
│   ├── playbook.yml                    # Docker install + run product-service container
│   ├── role-playbook.yml               # same, but via the reusable docker role
│   ├── configure-ec2.yml               # bootstrap: app user + Java 21 + ship JAR + systemd
│   ├── deploy-app.yml                  # pull image, replace container, healthcheck
│   └── templates/
│       └── product-service.service.j2  # systemd unit template
└── roles/
    └── docker/                         # reusable Docker install role
        ├── tasks/main.yml
        ├── handlers/main.yml
        ├── vars/main.yml
        └── defaults/main.yml
```

## Prerequisites

1. **Ansible** installed. On Windows use WSL or `pip3 install ansible`.
2. **Community Docker collection** (for `docker_image` / `docker_container`):
   ```bash
   ansible-galaxy collection install community.docker
   ```
3. **`docker` Python package on the targets** (the playbooks install it, but if
   bootstrapping manually: `pip3 install docker`).
4. **EC2 instances** running Amazon Linux 2023 reachable by SSH (or use the
   `infrastructure/terraform` EC2 — get its IP from `terraform output ec2_public_ip`).
5. **Docker image** pushed to a registry (the playbooks default to the
   `a22204317/product-service` Docker Hub image — change it to your own handle).

## Values to swap in before running

| Token | Replace with |
|---|---|
| `52.28.19.124` in `inventory/inventory.ini` | real public IP(s) of your EC2 instance(s) |
| `a22204317/product-service` in `playbooks/playbook.yml`, `deploy-app.yml` | your Docker Hub image (or ECR URI) |
| `~/.ssh/week6-key.pem` in `inventory/inventory.ini` | your EC2 SSH private key path |

## Smoke-test order

```bash
# from the ansible/ directory:

ansible --version

# inventory checks (ansible.cfg already points at inventory/inventory.ini)
ansible all -m ping
ansible-inventory -i inventory/inventory_aws_ec2.yml --graph

# Docker install + container run
ansible-playbook playbooks/playbook.yml

# same via the reusable role
ansible-playbook playbooks/role-playbook.yml
# then on the target: ssh ec2-user@<host> 'groups ec2-user && docker ps'

# bootstrap as a systemd service (build the JAR first:
#   mvn -pl product-service -am clean package -DskipTests)
ansible-playbook playbooks/configure-ec2.yml
# then: ssh ec2-user@<host> 'systemctl status product-service'

# rolling container deploy + healthcheck
IMAGE_TAG=1.0 ansible-playbook playbooks/deploy-app.yml
# then: ssh ec2-user@<host> 'docker ps && docker logs product-service'
```
