#!/bin/sh

set -eu

OS=$(uname -s)

need() { command -v "$1" >/dev/null 2>&1 || fail "Missing dependency: $1"; }

need install
need sed
need grep
need tar
if [ "$OS" = Linux ]; then need nfpm; else need pkg; fi

echo "[+] Generating package files"
nfpm package --config nfpm.yaml --packager deb --target ./packages/
nfpm package --config nfpm.yaml --packager rpm --target ./packages/

echo "[+] Done!"
