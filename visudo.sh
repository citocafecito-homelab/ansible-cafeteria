#!/bin/bash
set -euo pipefail

USER_NAME="barista"  # Cambia si quieres otro usuario
USER_SHELL="/bin/bash"

# Asegurarse de ser root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root o con sudo."
    exit 1
fi

echo "[1/5] Instalando sudo..."
apt-get update -y
apt-get install -y sudo

echo "[2/5] Creando usuario $USER_NAME si no existe..."
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s "$USER_SHELL" "$USER_NAME"
    echo "Usuario $USER_NAME creado."
else
    echo "Usuario $USER_NAME ya existe."
fi

echo "[3/5] Creando carpeta .ssh..."
mkdir -p "/home/$USER_NAME/.ssh"
chown "$USER_NAME:$USER_NAME" "/home/$USER_NAME/.ssh"
chmod 700 "/home/$USER_NAME/.ssh"

echo "[4/5] Configurando sudo sin contraseña..."
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USER_NAME"
chmod 0440 "/etc/sudoers.d/$USER_NAME"
chown root:root "/etc/sudoers.d/$USER_NAME"

echo "[5/5] Listo. El usuario $USER_NAME ahora tiene sudo sin contraseña."
