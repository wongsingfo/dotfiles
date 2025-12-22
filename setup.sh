#!/bin/bash
set -e

function show_help() {
    cat <<EOF
Usage: $0 [options]

Setup script for a new development machine.
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

# setup.sh - Setup script for a new development machine
# Installs tools and configurations based on the dotfiles repository.

echo "Starting setup..."

# Check if running on a Debian/Ubuntu based system
if [ -f /etc/debian_version ]; then
    echo "Detected Debian/Ubuntu system."
    
    # Update package list
    sudo apt-get update

    # Install apt packages
    echo "Installing system packages..."
    sudo apt-get install -y \
        7zip \
        bat \
        cmake \
        curl \
        fd-find \
        fish \
        fzf \
        gcc g++ \
        git \
        iproute2 \
        jq \
        make \
        python3 python3-pynvim python3-venv \
        ripgrep \
        rsync \
        stow \
        sudo \
        ssh sshpass \
        tmux \
        unzip \
        uuid-runtime \
        zoxide
else
    echo "Warning: Not on Debian/Ubuntu. Skipping apt package installation."
    echo "Please ensure you have the equivalent packages installed manually."
fi

# Install Node.js
if ! command -v node &> /dev/null; then
    echo "Installing Node.js (v24.4.0)..."
    curl -s https://nodejs.org/dist/v24.4.0/node-v24.4.0-linux-x64.tar.xz | sudo tar -xJ --strip-components=1 -C /usr/local
else
    echo "Node.js is already installed."
fi

# Install Global NPM Packages
echo "Installing global NPM packages..."
sudo npm install -g trzsz @anthropic-ai/claude-code @musistudio/claude-code-router

# Install Yazi (File Manager)
if ! command -v yazi &> /dev/null; then
    echo "Installing Yazi..."
    TEMP_DIR=$(mktemp -d)
    curl -L https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-musl.zip -o "$TEMP_DIR/yazi.zip"
    unzip "$TEMP_DIR/yazi.zip" -d "$TEMP_DIR"
    sudo cp "$TEMP_DIR/yazi-x86_64-unknown-linux-musl/ya" /usr/local/bin/
    sudo cp "$TEMP_DIR/yazi-x86_64-unknown-linux-musl/yazi" /usr/local/bin/
    rm -rf "$TEMP_DIR"
else
    echo "Yazi is already installed."
fi

# Install Neovim
if ! command -v nvim &> /dev/null; then
    echo "Installing Neovim (v0.11.2)..."
    curl -L https://github.com/neovim/neovim-releases/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz | sudo tar zxf - -C /usr/local/ --strip-components=1
else
    echo "Neovim is already installed."
fi

# Install uv and llm
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v llm &> /dev/null; then
    echo "Installing llm tool..."
    uv tool install llm
    llm install llm-openrouter
fi

# Install OpenCode
if ! command -v opencode &> /dev/null; then
    echo "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
else
    echo "OpenCode is already installed."
fi

# Install Rust (rustup)
if [[ "$INSTALL_RUST" == "true" ]]; then
    if ! command -v rustup &> /dev/null; then
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        echo "Rust installed."
    else
        echo "Rust is already installed."
    fi
else
    echo "Skipping Rust installation (INSTALL_RUST not set to true)."
fi

# Stow Dotfiles
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -d "$SCRIPT_DIR/stow-dotfiles" ]; then
    echo "Stowing dotfiles..."
    cd "$SCRIPT_DIR/stow-dotfiles"
    stow -t "$HOME" -R *
    cd "$SCRIPT_DIR"
else
    echo "Error: stow-dotfiles directory not found in $SCRIPT_DIR"
fi

# Setup Fish Shell
echo "Setting up Fish shell plugins..."
# Check if fish is in /etc/shells
if ! grep -q "$(which fish)" /etc/shells; then
    echo "Adding fish to /etc/shells..."
    which fish | sudo tee -a /etc/shells
fi

# Install Fisher and plugins
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install PatrickF1/fzf.fish'

# Configure .bashrc to start fish automatically (from README.md)
echo "Configuring .bashrc to automatically start fish..."
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    # Check if we already added it to avoid duplicates
    if ! grep -q "exec fish" "$BASHRC"; then
        cat >> "$BASHRC" << 'EOF'

if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]
then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec fish $LOGIN_OPTION
fi
EOF
        echo "Updated $BASHRC to launch fish."
    else
        echo "Fish launch logic already in $BASHRC."
    fi
fi

echo "==================================================="
echo "Setup complete!"
echo "Please restart your shell or log out and back in."
echo "Fish has been configured to launch automatically from .bashrc."
echo "==================================================="
