#!/bin/bash
set -e

function show_help() {
    cat <<EOF
Usage: $0 [options]

Setup script for a new development machine (macOS).
Installs tools and configurations based on the dotfiles repository.

Options:
  --help            Show this help message
  --install-rust    Install Rust (equivalent to setting INSTALL_RUST=true)

Environment Variables:
  INSTALL_RUST      Set to "true" to install Rust language support
EOF
    exit 0
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help ;;
        --install-rust) INSTALL_RUST=true ;;
        *) echo "Unknown parameter passed: $1"; echo "Use --help for usage information."; exit 1 ;;
    esac
    shift
done

# setup_macos.sh - Setup script for macOS
echo "[setup] Starting setup for macOS..."

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "[error] This script is intended for macOS only."
    exit 1
fi

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "[system] Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session (Apple Silicon vs Intel)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "[system] Homebrew is already installed."
fi

# Update Homebrew
echo "[system] Updating Homebrew..."
brew update

# Install packages via Homebrew
echo "[system] Installing packages via Homebrew..."
PACKAGES=(
    sevenzip
    bat
    cmake
    curl
    git
    jq
    make
    python
    ripgrep
    rsync
    stow
    unzip
    zoxide
    fish
    fzf
    fd
    tmux
    node
    yazi
    neovim
    uv
)

# Optional: sshpass (might need a specific tap or install method if not in core, but often is available via third party or just skip if tricky. 
# It's explicitly in the linux script so I'll try to add it via a common tap if needed, but for now I'll include it and let brew handle it if available or user can handle it.
# Actually sshpass is not in standard brew. Usually people use `brew install esolitos/ipa/sshpass`. 
# To be safe and simple, I will check if it's available or use the tap.)
echo "[sshpass] Checking for sshpass..."
if ! brew list sshpass &>/dev/null; then
     # Attempt to install from a common tap or warn
     brew install esolitos/ipa/sshpass || echo "[warning] Could not install sshpass via brew. You may need to install it manually."
else
    echo "[sshpass] sshpass already installed."
fi


brew install "${PACKAGES[@]}"

# Install llm (using uv tool which was installed via brew)
if ! command -v llm &> /dev/null; then
    echo "[llm] Installing llm tool..."
    uv tool install llm
    llm install llm-openrouter
else
    echo "[llm] llm is already installed."
fi

# Install Rust (rustup)
if [[ "$INSTALL_RUST" == "true" ]]; then
    if ! command -v rustup &> /dev/null; then
        echo "[rust] Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        echo "[rust] Rust installed."
    else
        echo "[rust] Rust is already installed."
    fi
else
    echo "[rust] Skipping Rust installation (INSTALL_RUST not set to true)."
fi

# Stow Dotfiles
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -d "$SCRIPT_DIR/stow-dotfiles" ]; then
    echo "[stow] Stowing dotfiles..."
    cd "$SCRIPT_DIR/stow-dotfiles"
    stow -t "$HOME" -R *
    cd "$SCRIPT_DIR"
else
    echo "[stow] Error: stow-dotfiles directory not found in $SCRIPT_DIR"
fi

# Setup Fish Shell
echo "[fish] Setting up Fish shell..."
echo "[fish] Fish version: $(fish --version)"

# Install Fisher and plugins
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install PatrickF1/fzf.fish'

# Configure shell to start fish automatically
# macOS default is zsh. We'll modify .zshrc.
echo "[shell] Configuring .zshrc to automatically start fish..."
RC_FILE="$HOME/.zshrc"

if [ -f "$RC_FILE" ] || [ ! -e "$RC_FILE" ]; then
    # Create if likely empty or append
    touch "$RC_FILE"
    if ! grep -q "exec fish" "$RC_FILE"; then
        cat >> "$RC_FILE" << 'EOF'

if [[ $(ps -p $$ -o comm=) != "fish" && -z ${ZSH_EXECUTION_STRING} && ${SHLVL} == 1 ]]; then
    exec fish
fi
EOF
        echo "[shell] Updated $RC_FILE to launch fish."
    else
        echo "[shell] Fish launch logic already in $RC_FILE."
    fi
fi

echo "==================================================="
echo "[setup] Setup complete!"
echo "[setup] Please restart your terminal."
echo "==================================================="
