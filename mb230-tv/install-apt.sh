#!/bin/sh
set -e
PREFIX="${PREFIX:-/mtd_rwarea/opt/apt}"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BUNDLE="$SRC_DIR/apt-bundle-armhf.tar.gz"

echo "[*] Installing APT/dpkg bundle to $PREFIX"
if [ ! -f "$BUNDLE" ]; then
  echo "ERROR: missing $BUNDLE" >&2
  exit 1
fi
mkdir -p "$PREFIX"
rm -rf "$PREFIX/bin" "$PREFIX/lib" "$PREFIX/etc" "$PREFIX/var"
tar -C "$PREFIX" -xzf "$BUNDLE"

mkdir -p "$PREFIX/var/lib/dpkg" "$PREFIX/var/cache/apt/archives/partial" "$PREFIX/var/lib/apt/lists/partial" \
         "$PREFIX/etc/apt/apt.conf.d" "$PREFIX/etc/apt/preferences.d" "$PREFIX/etc/apt/sources.list.d" "$PREFIX/etc/apt/trusted.gpg.d"
[ -f "$PREFIX/var/lib/dpkg/status" ] || : > "$PREFIX/var/lib/dpkg/status"

cat > "$PREFIX/bin/apt-run" <<'WRAP'
#!/bin/sh
PREFIX="/mtd_rwarea/opt/apt"
export APT_CONFIG="$PREFIX/etc/apt/apt.conf"
export LD_LIBRARY_PATH="$PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PATH="$PREFIX/bin:$PATH"
exec "$@"
WRAP
chmod +x "$PREFIX/bin/apt-run"

mkdir -p "$PREFIX/bin/.real"
for f in apt apt-get apt-cache apt-config apt-cdrom apt-extracttemplates apt-ftparchive apt-mark apt-sortpkgs dpkg dpkg-deb dpkg-divert dpkg-query dpkg-split dpkg-statoverride dpkg-trigger gpgv gpgv2; do
  if [ -f "$PREFIX/bin/$f" ] && [ ! -h "$PREFIX/bin/$f" ]; then
    if head -c 2 "$PREFIX/bin/$f" 2>/dev/null | grep -q '#!'; then
      :
    else
      mv "$PREFIX/bin/$f" "$PREFIX/bin/.real/$f"
      cat > "$PREFIX/bin/$f" <<WRAP
#!/bin/sh
exec "/mtd_rwarea/opt/apt/bin/apt-run" "/mtd_rwarea/opt/apt/bin/.real/$f" "\$@"
WRAP
      chmod +x "$PREFIX/bin/$f"
    fi
  fi
done

for c in apt apt-get apt-cache apt-config apt-mark apt-ftparchive dpkg dpkg-deb dpkg-query gpgv; do
  if [ -x "$PREFIX/bin/$c" ] || [ -f "$PREFIX/bin/$c" ]; then
    cat > "$PREFIX/bin/${c}.tv" <<WRAP
#!/bin/sh
exec /mtd_rwarea/opt/apt/bin/apt-run /mtd_rwarea/opt/apt/bin/$c "\$@"
WRAP
    chmod +x "$PREFIX/bin/${c}.tv"
  fi
done

cat > "$PREFIX/activate.sh" <<'ACT'
#!/bin/sh
export PATH="/mtd_rwarea/opt/apt/bin:$PATH"
echo "APT/dpkg environment activated: /mtd_rwarea/opt/apt/bin"
ACT
chmod +x "$PREFIX/activate.sh"

echo "[*] Installed."
echo "    $PREFIX/bin/apt-get --version"
echo "    $PREFIX/bin/dpkg --version"
echo "[*] Add to PATH: export PATH=\"$PREFIX/bin:\$PATH\" (or: . $PREFIX/activate.sh)"
