#!/bin/sh

set -eu

# Require root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root." >&2
    echo "Usage: sudo sh $0" >&2
    exit 1
fi

# Determine project directories
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"
output_dir="$project_root/output"
logs_dir="$output_dir/logs"

# Clear any old builds
rm -rf $output_dir

# Create the logs directory and output directory
mkdir -p "$logs_dir"

. $script_dir/generate_key.sh

# Detect operating system
os="$(uname -s)"

echo "[+] Operating system: $os"
echo "[+] Project root: $project_root"

# Install build dependencies
echo "[+] Installing build dependencies..."

case "$os" in
    FreeBSD)
        pkg install -y \
            gmake \
            autoconf \
            automake \
            pkgconf
        ;;

    Linux)
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update
            apt-get install -y \
                build-essential \
                autoconf \
                automake \
                libssl-dev \
                zlib1g-dev \
                libpam0g-dev \
                pkg-config

        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y \
                gcc \
                make \
                autoconf \
                automake \
                openssl-devel \
                zlib-devel \
                pam-devel \
                pkgconf-pkg-config

        elif command -v yum >/dev/null 2>&1; then
            yum install -y \
                gcc \
                make \
                autoconf \
                automake \
                openssl-devel \
                zlib-devel \
                pam-devel \
                pkgconfig

        elif command -v pacman >/dev/null 2>&1; then
            pacman -S --needed --noconfirm \
                base-devel \
                autoconf \
                automake \
                openssl \
                zlib \
                pam \
                pkgconf

        elif command -v zypper >/dev/null 2>&1; then
            zypper install -y \
                gcc \
                make \
                autoconf \
                automake \
                libopenssl-devel \
                zlib-devel \
                pam-devel \
                pkg-config

        elif command -v apk >/dev/null 2>&1; then
            apk add \
                build-base \
                autoconf \
                automake \
                openssl-dev \
                zlib-dev \
                linux-pam-dev \
                pkgconf

        else
            echo "Error: Unsupported package manager." >&2
            exit 1
        fi
        ;;

    *)
        echo "Error: Unsupported operating system: $os" >&2
        exit 1
        ;;
esac

# Verify required tools
echo "[+] Checking build tools..."

for tool in autoreconf cc ssh-keygen; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Error: Required tool not found: $tool" >&2
        exit 1
    fi
done

if [ "$os" = "FreeBSD" ]; then
    build_make="gmake"
else
    build_make="make"
fi

if ! command -v "$build_make" >/dev/null 2>&1; then
    echo "Error: Make utility not found: $build_make" >&2
    exit 1
fi

# Determine parallel job count
if command -v nproc >/dev/null 2>&1; then
    jobs="$(nproc)"
elif [ "$os" = "FreeBSD" ]; then
    jobs="$(sysctl -n hw.ncpu)"
else
    jobs=1
fi

echo "[+] Build environment ready."

# Generate the configure script
echo "[+] Running autoreconf..."
cd "$project_root"
autoreconf -fi

# Configure the project
echo "[+] Configuring project..."
"$project_root/configure" \
    --prefix="$output_dir" \
    --with-pam

# Build
echo "[+] Building project..."
"$build_make" -j "$jobs"

# Install
echo "[+] Installing project..."
"$build_make" install

echo "[+] Installation complete!"
echo "[+] Output directory: $project_root/output"
echo "[+] Build logs in: $project_root/output/logs"
echo "[+] SSH keys in: $project_root/output/keys"
echo "[+] Done! Share '$key_path' securely with teammates."
