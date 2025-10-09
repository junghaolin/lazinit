#!/usr/bin/env bash
# setup-usb-serial.sh
# Enable USB-to-Serial (TTL) on a fresh Debian/Ubuntu cloud-init VM.
# - Installs linux-modules-extra for current kernel
# - Installs minicom
# - Adds the invoking user to 'dialout'
# - Loads common USB serial drivers now and at boot

set -euo pipefail

echo "==> Detecting target user"
# If run via sudo, prefer the real invoking user
TARGET_USER="${SUDO_USER:-${USER}}"
if [[ -z "${TARGET_USER}" || "${TARGET_USER}" == "root" ]]; then
  # Fallback to first non-root user with a login shell
  TARGET_USER="$(awk -F: '$3>=1000 && $1!="nobody" {print $1; exit}' /etc/passwd || true)"
fi
: "${TARGET_USER:=root}"
echo "    target user: ${TARGET_USER}"

echo "==> Refreshing apt and installing packages (non-interactive)"
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get update -y
# linux-modules-extra provides most out-of-tree/optional drivers for the running kernel
EXTRA_PKG="linux-modules-extra-$(uname -r)"
sudo -E apt-get install -y --no-install-recommends "${EXTRA_PKG}" minicom ca-certificates

echo "==> Ensuring user is in 'dialout' group"
if id -nG "${TARGET_USER}" | grep -qw dialout; then
  echo "    ${TARGET_USER} already in dialout"
else
  sudo usermod -aG dialout "${TARGET_USER}"
  echo "    Added ${TARGET_USER} to dialout (re-login required to take effect)"
fi

echo "==> Set modules to autoload at boot"
MODULES_CONF="/etc/modules-load.d/usb-serial.conf"
sudo tee "${MODULES_CONF}" >/dev/null <<'EOF'
# Common USB serial drivers for USB-to-TTL dongles
usbserial
ch341
cp210x
ftdi_sio
pl2303
cdc_acm
EOF
echo "    Wrote ${MODULES_CONF}"

echo "==> Load modules now (safe if already loaded)"
for m in usbserial ch341 cp210x ftdi_sio pl2303 cdc_acm; do
  sudo modprobe "${m}" 2>/dev/null || true
done

echo "==> Quick sanity checks"
echo "    Kernel: $(uname -r)"
echo "    Modules loaded:"
lsmod | egrep 'usbserial|ch341|cp210x|ftdi_sio|pl2303|cdc_acm' || true

echo "==> Usage hint"
cat <<'HINT'
- 插上你的 USB-to-TTL 轉接器後，執行：
    dmesg | grep -E 'tty(USB|ACM)'
    ls -l /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
- 連線（常見鮑率 115200）：
    minicom -D /dev/ttyUSB0 -b 115200
  或
    minicom -D /dev/ttyACM0 -b 115200
- 若 /dev 權限仍受限，請重新登入或 newgrp dialout 讓群組生效：
    newgrp dialout
HINT

echo "==> Done.

