# Ansible Playbook

Este repositorio contiene un playbook de Ansible para automatizar la instalación de un clúster de Kubernetes en sistemas operativos Debian. También configura Netplan para implementar la agregación de enlaces (link aggregation), optimizando el rendimiento y la redundancia de red.

## 📝 Contenido del Repositorio

[playbook.yml](./playbook.yml): El archivo principal del playbook de Ansible que orquesta todas las tareas.

[inventory.ini](./inventory.ini): Archivo de inventario para definir los nodos (control-plane y workers) del clúster.

[roles/k8s](./roles/k8s/): Rol de Ansible para la instalación de Kubernetes.

[group_vars/all.yml](./group_vars/all.yml): Variables globales para todo el clúster.

## 🚀 Requisitos Previos

Ansible: Asegúrate de tener Ansible instalado en tu máquina de control.

Sistemas Operativos: Los nodos de destino deben ser Debian 13 o superior.

Conectividad: Los nodos deben tener acceso a Internet para descargar los paquetes necesarios.

Agregación de Enlaces: El host debe tener al menos dos interfaces de red físicas disponibles y no configuradas.

## 🛠️ Uso

1. Configurar el Inventario

    Edita el archivo inventario.ini para definir los hosts que formarán parte del clúster de Kubernetes.

1. Ejecutar el Playbook

    Ejecuta el playbook de Ansible. Ansible se conectará a los hosts definidos, instalará las dependencias, configurará la agregación de enlaces y desplegará Kubernetes.

    ```bash
    ansible-playbook playbook.yml
    ```

## ⚙️ Configuración de Netplan

El playbook está configurado para crear una interfaz de red bond0 utilizando las interfaces eth0 y eth1. Puedes ajustar estas configuraciones en las variables del rol netplan si tus nombres de interfaz son diferentes. El modo de agregación de enlaces predeterminado es mode: 802.3ad (LACP).

```yaml
netplan:
  enabled: true
  renderer: networkd
  mode: "802.3ad"
  miimon: "100"
  lacp_rate: "fast"
  interfaces:
    eth1:
      addresses:
        - 192.168.1.20/24
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
    eth2:
      addresses:
        - 192.168.1.20/24
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```
