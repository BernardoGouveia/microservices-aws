# Role: docker

Installs Docker CE on Amazon Linux 2 (CentOS 7-compatible repo), starts the service, and adds named users to the `docker` group.

## Required variables

| Variable | Description | Default |
|---|---|---|
| `docker_users` | List of OS users to add to the `docker` group | `[]` |

## Example usage

```yaml
- hosts: all
  become: yes
  roles:
    - role: docker
      vars:
        docker_users:
          - ec2-user
          - app-user
```

## Handlers

- `restart docker` — fires after package install / service config changes.
