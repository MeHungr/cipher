#!/usr/bin/env bash

OS=$(uname -s)

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root or using sudo."
  exit 1
fi

echo "🔍 Detecting Linux distribution..."

# Detect OS using /etc/os-release
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_LIKE=${ID_LIKE:-""}
else
    echo "❌ Could not detect OS via /etc/os-release."
    exit 1
fi

# Route installation based on detected OS
case "$OS_ID" in
    ubuntu|debian|mint|pop)
        echo "📦 Detected $NAME. Installing via APT..."
        echo 'deb [trusted=yes] https://repo.goreleaser.com/apt/ /' | tee /etc/apt/sources.list.d/goreleaser.list
        apt-get update
        apt-get install -y nfpm
        ;;
    
    fedora|rhel|centos|rocky|almalinux)
        echo "📦 Detected $NAME. Installing via DNF/YUM..."
        echo '[goreleaser]
name=GoReleaser
baseurl=https://repo.goreleaser.com/yum/
enabled=1
gpgcheck=0' | sudo tee /etc/yum.repos.d/goreleaser.repo
sudo yum install nfpm
        if command -v dnf &> /dev/null; then
            dnf install -y nfpm
        else
            yum install -y nfpm
        fi
        ;;
    *)
        # Fallback check for derivatives via ID_LIKE
        if [[ "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
            echo "📦 Detected Debian/Ubuntu derivative ($NAME). Installing via APT..."
            echo 'deb [trusted=yes] https://repo.goreleaser.com/apt /' | tee /etc/apt/sources.list.d/goreleaser.list
            apt-get update
            apt-get install -y nfpm
        elif [[ "$OS_LIKE" == *"rhel"* || "$OS_LIKE" == *"fedora"* ]]; then
            echo "📦 Detected RHEL/        echo '[goreleaser]
name=GoReleaser
baseurl=https://repo.goreleaser.com/yum/
enabled=1
gpgcheck=0' | sudo tee /etc/yum.repos.d/goreleaser.repo
sudo yum install nfpmFedora derivative ($NAME). Installing via DNF/YUM..."
            if command -v dnf &> /dev/null; then dnf install -y nfpm; else yum install -y nfpm; fi
        else
            echo "⚠️ Unsupported or unknown distribution: $NAME"
            echo "⚙️ Falling back to generic binary download..."
            
            if ! command -v curl &> /dev/null; then
                echo "❌ curl is required for fallback installation. Please install curl and try again."
                exit 1
            fi
            
            # Download and run the official GoReleaser/nFPM shell installer script
            curl -sfL https://goreleaser.com | bash
        fi
        ;;
esac

# Verify the installation
if command -v nfpm &> /dev/null; then
    echo "🎉 Success! nFPM $(nfpm --version | head -n 1) has been installed."
else
    echo "❌ Installation completed, but 'nfpm' binary was not found in PATH."
    exit 1
fi

need() { command -v "$1" >/dev/null 2>&1 || fail "Missing dependency: $1"; }

need install
need sed
need grep
need tar
if [ "$OS" = Linux ]; then need nfpm; else need pkg; fi

mkdir -p ./packages

echo "[+] Generating package files"
nfpm package --config nfpm.yaml --packager deb --target ./packages/
nfpm package --config nfpm.yaml --packager rpm --target ./packages/

mkdir -p ../deploy/roles/cipher/files
cp ./packages/* ../deploy/roles/cipher/files/

echo "[+] Done!"
