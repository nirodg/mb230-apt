#!/bin/sh
set -e
BASE="${BASE:-https://raw.githubusercontent.com/nirodg/mb230-apt/main/mb230-tv}"
DEST="${DEST:-/tmp/apt-install-bin}"
mkdir -p "$DEST"
cd "$DEST"
echo "[*] Downloading mb230 TV apt/dpkg bundle..."
wget -O apt-bundle-armhf.tar.gz "$BASE/apt-bundle-armhf.tar.gz"
wget -O install-apt.sh "$BASE/install-apt.sh"
chmod +x install-apt.sh
echo "[*] Running installer..."
sh install-apt.sh
echo "[*] Done. Open a new shell or run: export PATH=/mtd_rwarea/opt/apt/bin:\$PATH"
