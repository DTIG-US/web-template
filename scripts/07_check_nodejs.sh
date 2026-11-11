#!/usr/bin/env bash
set -eo pipefail

TARGET_VERSION="22.22.3"
TARGET_SEMVER="v${TARGET_VERSION}"

# Load NVM if installed
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
fi

echo "[*] Checking local Node.js installations..."

# Function to sanitize hardcoded paths in dotfiles
sanitize_shell_configs() {
    local old_pattern="v20.12.1"
    local config_files=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.zshrc")

    for cfg in "${config_files[@]}"; do
        if [ -f "$cfg" ] && grep -q "$old_pattern" "$cfg"; then
            echo "[!] Found legacy Node version in $cfg. Updating to $TARGET_SEMVER..."
            sed -i "s/$old_pattern/$TARGET_SEMVER/g" "$cfg"
        fi
    done
}

# Determine installed versions via NVM or system
if command -v nvm >/dev/null 2>&1; then
    # List local versions installed via NVM
    INSTALLED_VERSIONS=$(nvm ls --no-colors | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -u || true)
    
    if echo "$INSTALLED_VERSIONS" | grep -qx "$TARGET_SEMVER"; then
        echo "[✓] Target version $TARGET_SEMVER is already installed."
    else
        echo "[+] Installing Node.js $TARGET_SEMVER via nvm..."
        nvm install "$TARGET_VERSION"
    fi

    # Set as default alias and activate in current shell
    echo "[*] Setting default alias and updating active version..."
    nvm alias default "$TARGET_VERSION"
    nvm use "$TARGET_VERSION"

else
    # Fallback for systems without NVM
    CURRENT_VERSION=$(node -v 2>/dev/null || echo "none")

    if [ "$CURRENT_VERSION" != "$TARGET_SEMVER" ]; then
        echo "[!] NVM not found. Current Node is $CURRENT_VERSION. Installing $TARGET_SEMVER via binary..."
        
        ARCH=$(uname -m)
        case "$ARCH" in
            x86_64)  ARCH_NAME="x64" ;;
            aarch64) ARCH_NAME="arm64" ;;
            *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
        esac

        TARBALL="node-${TARGET_SEMVER}-linux-${ARCH_NAME}.tar.xz"
        DOWNLOAD_URL="https://nodejs.org/dist/${TARGET_SEMVER}/${TARBALL}"
        INSTALL_DIR="/usr/local"

        mkdir -p /tmp/node_update
        curl -fsSL "$DOWNLOAD_URL" -o "/tmp/node_update/$TARBALL"
        sudo tar -xJf "/tmp/node_update/$TARBALL" -C "$INSTALL_DIR" --strip-components=1 --no-same-owner
        rm -rf /tmp/node_update
    else
        echo "[✓] Node.js is already at $TARGET_SEMVER."
    fi
fi

# Sanitize dotfiles and active PATH
sanitize_shell_configs

# Strip old v20.12.1 entries from active PATH in current process
NEW_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v 'v20.12.1' | tr '\n' ':' | sed 's/:$//')
export PATH="$NEW_PATH"

echo "=========================================="
echo "Active Node: $(node -v) ($(which node))"
echo "Active npm:  $(npm -v) ($(which npm))"
echo "=========================================="
