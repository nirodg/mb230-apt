# APT/dpkg bundle for Vestel MB230 TV (armv7l)

Prebuilt CLI package-management bundle for MB230 TVs (ARMv7, Linux 4.9, glibc ~2.23), built from Debian Jessie armhf packages (`apt 1.0.9.8.6`, `dpkg 1.17.27`) with bundled libraries and wrappers.

## Quick install (on TV over SSH/telnet)

```sh
cd /tmp
BASE="https://raw.githubusercontent.com/nirodg/mb230-apt/main/mb230-tv"
wget -O apt-bundle-armhf.tar.gz "$BASE/apt-bundle-armhf.tar.gz"
wget -O install-apt.sh "$BASE/install-apt.sh"
chmod +x install-apt.sh
sh install-apt.sh
```

Installs to `/mtd_rwarea/opt/apt` by default (persistent writable storage). Override with `PREFIX=/some/path sh install-apt.sh`.

## Usage

```sh
export PATH=/mtd_rwarea/opt/apt/bin:$PATH
# or: . /mtd_rwarea/opt/apt/activate.sh

apt-get --version
dpkg --version
apt-get update
```

Direct execution works (`/mtd_rwarea/opt/apt/bin/apt-get ...`) via bundled wrappers/libs.

## Defaults included

- `sources.list` preconfigured with archived Debian Jessie armhf repos (`archive.debian.org`, `[trusted=yes]`) for compatibility with this bundle.
- Minimal APT/dpkg config dirs (`preferences.d`, `sources.list.d`, `trusted.gpg.d`, `apt.conf.d`) and dpkg status file.
- `gpgv` shim and bundled dependencies to reduce common setup friction.

## Notes

- Jessie is EOL/archived; repos are provided as convenience defaults. Adjust `/mtd_rwarea/opt/apt/etc/apt/sources.list` for your environment.
- This is a userspace bundle installed under `/mtd_rwarea/opt/apt`; it does not modify the TV’s stock squashfs/UBI system.
- Full package management depends on repository compatibility with this device’s kernel/userspace.
