# Ansible RouterOS Neutro

Configuración para eliminar el router del ISP usando Ansible

```bash
ssh admin@192.168.88.1
```

```bash
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "192.168.88.1"
```

```bash
ansible-playbook playbook.yml
```

```bash
ansible-playbook playbook.yml -e ansible_debug=true
```
