==============================
Guía rápida: i5-14450HK + Debian 13 + iGPU
==============================

1️⃣ Actualizar BIOS
- Descargar la última BIOS de tu placa / mini-PC.
- Buscar en changelog:
    • Soporte Intel 14ª gen
    • Corrección de estabilidad / microcode
- Flashear siguiendo guía oficial.

2️⃣ Ajustes de BIOS / UEFI
- C-States profundos → OFF o Auto (limita a C1)
- ASPM (PCIe power saving) → OFF
- iGPU DVMT Pre-Allocated → ≥ 128 MB
- XMP / perfiles RAM → OFF
- Intel Baseline Profile → ON (si existe)

3️⃣ Configuración de kernel en Debian
Editar `/etc/default/grub`:

GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_idle.max_cstate=1 pcie_aspm=off i915.enable_psr=0 i915.enable_dc=0"

Actualizar GRUB y reiniciar:

sudo update-grub
sudo reboot

⚡ Explicación:
- intel_idle.max_cstate=1 → evita que CPU se quede dormido
- pcie_aspm=off → evita freezes de buses PCIe
- i915.enable_psr=0 → desactiva Panel Self Refresh de iGPU
- i915.enable_dc=0 → desactiva Display C-states de iGPU

4️⃣ Microcode Intel
sudo apt update
sudo apt install intel-microcode
sudo reboot

5️⃣ Swap recomendada
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

6️⃣ Verificar iGPU y Quick Sync
ls -l /dev/dri
dmesg | grep i915

Deberías ver:
- /dev/dri/card0
- /dev/dri/renderD128
Sin errores en dmesg → iGPU estable para Jellyfin.

7️⃣ Prueba final
- Dejar sistema idle 15–30 min
- Si no se congela → listo para Jellyfin y k8s

==============================
Fin de guía rápida
==============================
