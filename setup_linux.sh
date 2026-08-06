#!/bin/bash
set -e

# Resolve script directory up-front, before any `cd` later in the script can
# break a relative ${BASH_SOURCE[0]} (e.g. when invoked as ./setup_linux.sh).
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GIT_TARGET_VERSION="2.55.0"
GIT_SOURCE_ARCHIVE="git-${GIT_TARGET_VERSION}.tar.xz"
GIT_SOURCE_SHA256="457fdb04dc8728e007d4688695e6912e6f680727920f2a40bf11eacc17505357"
GIT_SOURCE_URL="https://www.kernel.org/pub/software/scm/git/${GIT_SOURCE_ARCHIVE}"

function ensure_git_version() {
    local current_git_version
    current_git_version="$(git --version | awk '{print $3}')"

    if dpkg --compare-versions "$current_git_version" ge "$GIT_TARGET_VERSION"; then
        echo "[git] Git $current_git_version already satisfies >= $GIT_TARGET_VERSION."
        return
    fi

    echo "[git] Git $current_git_version is older than $GIT_TARGET_VERSION; building from source..."
    sudo apt-get install -y \
        gettext libcurl4-openssl-dev libexpat1-dev libssl-dev perl xz-utils zlib1g-dev

    local git_build_dir
    local git_source_dir
    git_build_dir="$(mktemp -d)"
    git_source_dir="$git_build_dir/git-${GIT_TARGET_VERSION}"

    (
        trap 'rm -rf "$git_build_dir"' EXIT

        curl --fail --location --show-error \
            "$GIT_SOURCE_URL" \
            --output "$git_build_dir/$GIT_SOURCE_ARCHIVE"
        printf '%s  %s\n' \
            "$GIT_SOURCE_SHA256" \
            "$git_build_dir/$GIT_SOURCE_ARCHIVE" \
            | sha256sum --check -
        tar -xJf "$git_build_dir/$GIT_SOURCE_ARCHIVE" -C "$git_build_dir"

        make -C "$git_source_dir" \
            -j"$(nproc)" \
            prefix=/usr/local \
            NO_RUST=YesPlease \
            NO_TCLTK=YesPlease \
            all
        "$git_source_dir/bin-wrappers/git" --version
        sudo make -C "$git_source_dir" \
            prefix=/usr/local \
            NO_RUST=YesPlease \
            NO_TCLTK=YesPlease \
            install
    )

    export PATH="/usr/local/bin:$PATH"
    hash -r
    current_git_version="$(git --version | awk '{print $3}')"
    if ! dpkg --compare-versions "$current_git_version" ge "$GIT_TARGET_VERSION"; then
        echo "[git] Error: expected Git >= $GIT_TARGET_VERSION, found $current_git_version." >&2
        exit 1
    fi
    echo "[git] Git $current_git_version installed successfully at $(command -v git)."
}

function show_help() {
    cat <<EOF
Usage: $0 [options]

Setup script for a new development machine.
Installs tools and configurations based on the dotfiles repository.

Options:
  --help            Show this help message
EOF
    exit 0
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help ;;
        *) echo "Unknown parameter passed: $1"; echo "Use --help for usage information."; exit 1 ;;
    esac
    shift
done

# setup.sh - Setup script for a new development machine
# Installs tools and configurations based on the dotfiles repository.

echo "[setup] Starting setup..."

# Check if running on a Debian/Ubuntu based system
if [ -f /etc/debian_version ]; then
    echo "[system] Detected Debian/Ubuntu system."

    # Update package list
    sudo apt-get update

    # Install apt packages
    echo "[system] Installing system packages..."
    # Packages that may not exist on older Debian; install individually to tolerate missing ones
    APT_PACKAGES=(
        ca-certificates cmake curl gcc g++ git gnupg iproute2 jq
        libevent-dev libncurses5-dev libncursesw5-dev
        make python3 python3-pip python3-venv ripgrep rsync
        software-properties-common stow sudo ssh sshpass
        unzip uuid-runtime
    )
    # Try distribution-specific names
    for pkg in "7zip" "p7zip-full"; do
        if apt-cache show "$pkg" &>/dev/null; then APT_PACKAGES+=("$pkg"); break; fi
    done
    if apt-cache show "python3-pynvim" &>/dev/null; then APT_PACKAGES+=("python3-pynvim"); fi
    if apt-cache show "zoxide" &>/dev/null; then APT_PACKAGES+=("zoxide"); fi

    sudo apt-get install -y "${APT_PACKAGES[@]}"

    # diffview-plus.nvim requires Git >= 2.31. Pin the current upstream Git
    # release when an older distro package (such as Debian buster's) is found.
    ensure_git_version

    # Install pynvim via pip if apt package unavailable
    if ! python3 -c "import pynvim" &>/dev/null; then
        echo "[system] Installing pynvim via pip3..."
        python3 -m pip install --user pynvim 2>/dev/null || pip3 install --user pynvim 2>/dev/null || sudo python3 -m pip install pynvim
    fi

    # Install zoxide from GitHub if not available via apt
    if ! command -v zoxide &>/dev/null; then
        echo "[zoxide] Installing zoxide from GitHub..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Install Fish shell
    if ! command -v fish &> /dev/null; then
        if [ -f /etc/lsb-release ] && grep -q Ubuntu /etc/lsb-release 2>/dev/null; then
            # Ubuntu: use PPA for latest Fish 4.x
            echo "[fish] Installing Fish shell from PPA (Ubuntu)..."
            sudo add-apt-repository -y ppa:fish-shell/release-4
            sudo apt-get update
            sudo apt-get install -y fish
        else
            # Debian: try backports first, fallback to repo version
            echo "[fish] Installing Fish shell (Debian)..."
            DISTRO_CODENAME=$(lsb_release -cs 2>/dev/null || (. /etc/os-release && echo "$VERSION_CODENAME"))
            if sudo apt-get install -y -t "${DISTRO_CODENAME}-backports" fish 2>/dev/null; then
                echo "[fish] Installed Fish from backports."
            else
                echo "[fish] Backports not available, installing from default repo..."
                sudo apt-get install -y fish
            fi
        fi
    else
        echo "[fish] Fish is already installed."
    fi

    # Install Docker
    if ! command -v docker &> /dev/null; then
        echo "[docker] Installing Docker from official apt repo..."
        . /etc/os-release
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL "https://download.docker.com/linux/${ID}/gpg" \
            | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        if ! id -nG "$USER" | grep -qw docker; then
            echo "[docker] Adding $USER to docker group (re-login required to take effect)..."
            sudo usermod -aG docker "$USER"
        fi
    else
        echo "[docker] Docker is already installed."
    fi
else
    echo "[system] Warning: Not on Debian/Ubuntu. Skipping apt package installation."
    echo "[system] Please ensure you have the equivalent packages installed manually."
fi


# Install latest fzf from GitHub releases
if ! command -v fzf &> /dev/null; then
    echo "[fzf] Installing latest fzf from GitHub..."
    curl -L "https://github.com/junegunn/fzf/releases/download/v0.67.0/fzf-0.67.0-linux_amd64.tar.gz" -o /tmp/fzf.tar.gz
    sudo tar -xzf /tmp/fzf.tar.gz -C /tmp
    sudo mv /tmp/fzf /usr/local/bin/
    sudo chmod +x /usr/local/bin/fzf
    rm /tmp/fzf.tar.gz
    echo "[fzf] fzf installed successfully."
else
    echo "[fzf] fzf is already installed."
fi

# Install fd from GitHub releases
if ! command -v fd &> /dev/null; then
    echo "[fd] Installing fd from GitHub..."
    sudo curl -L "https://github.com/sharkdp/fd/releases/download/v10.3.0/fd-v10.3.0-x86_64-unknown-linux-gnu.tar.gz" -o /tmp/fd.tar.gz
    sudo tar -xzf /tmp/fd.tar.gz -C /tmp
    sudo mv /tmp/fd-v10.3.0-x86_64-unknown-linux-gnu/fd /usr/local/bin/
    sudo chmod +x /usr/local/bin/fd
    rm -rf /tmp/fd.tar.gz /tmp/fd-v10.3.0-x86_64-unknown-linux-gnu
    echo "[fd] fd installed successfully."
else
    echo "[fd] fd is already installed."
fi

# Install tmux from source
if ! command -v tmux &> /dev/null; then
    echo "[tmux] Installing tmux (v3.6a) from source..."
    TMUX_TEMP_DIR=$(mktemp -d)
    cd "$TMUX_TEMP_DIR"
    curl -L https://github.com/tmux/tmux/releases/download/3.6a/tmux-3.6a.tar.gz -o tmux-3.6a.tar.gz
    tar xzf tmux-3.6a.tar.gz
    cd tmux-3.6a
    ./configure --prefix=/usr/local CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib"
    make
    sudo make install
    cd /
    rm -rf "$TMUX_TEMP_DIR"
    echo "[tmux] tmux installed successfully."
else
    echo "[tmux] tmux is already installed."
fi

# Install Node.js
if ! command -v node &> /dev/null; then
    echo "[node] Installing Node.js (v24.4.0)..."
    curl -s https://nodejs.org/dist/v24.4.0/node-v24.4.0-linux-x64.tar.xz | sudo tar -xJ --strip-components=1 -C /usr/local
else
    echo "[node] Node.js is already installed."
fi

# Install Yazi (File Manager)
if ! command -v yazi &> /dev/null; then
    echo "[yazi] Installing Yazi..."
    TEMP_DIR=$(mktemp -d)
    curl -L https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-musl.zip -o "$TEMP_DIR/yazi.zip"
    unzip "$TEMP_DIR/yazi.zip" -d "$TEMP_DIR"
    sudo cp "$TEMP_DIR/yazi-x86_64-unknown-linux-musl/ya" /usr/local/bin/
    sudo cp "$TEMP_DIR/yazi-x86_64-unknown-linux-musl/yazi" /usr/local/bin/
    rm -rf "$TEMP_DIR"
else
    echo "[yazi] Yazi is already installed."
fi

# Install Neovim
if ! command -v nvim &> /dev/null; then
    echo "[neovim] Installing Neovim (v0.12.2)..."
    curl -L https://github.com/neovim/neovim-releases/releases/download/v0.12.2/nvim-linux-x86_64.tar.gz | sudo tar zxf - -C /usr/local/ --strip-components=1
else
    echo "[neovim] Neovim is already installed."
fi

# Install uv
if ! command -v uv &> /dev/null; then
    echo "[uv] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Install OpenCode
if ! command -v opencode &> /dev/null; then
    echo "[opencode] Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
else
    echo "[opencode] OpenCode is already installed."
fi

# Install Rust (rustup)
if ! command -v rustup &> /dev/null; then
    echo "[rust] Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    echo "[rust] Rust installed."
else
    echo "[rust] Rust is already installed."
fi

# Stow Dotfiles
if [ -d "$SCRIPT_DIR/stow-dotfiles" ]; then
    echo "[stow] Stowing dotfiles..."
    cd "$SCRIPT_DIR/stow-dotfiles"

    # Pre-resolve conflicts: stow refuses to overwrite existing regular files
    # (e.g. ~/.config/fish/fish_variables auto-created by fish on first run,
    #  ~/.claude/settings.json created by Claude Code). Back them up to .bak
    # so stow can plant its symlink.
    for pkg in */; do
        pkg="${pkg%/}"
        while IFS= read -r -d '' src; do
            rel="${src#$pkg/}"
            target="$HOME/$rel"
            if [ -e "$target" ] && [ ! -L "$target" ] && [ ! -d "$target" ]; then
                echo "[stow] Backing up conflicting $target -> $target.bak"
                mv "$target" "$target.bak"
            fi
        done < <(find "$pkg" -type f -print0)
    done

    stow -t "$HOME" -R */
    cd "$SCRIPT_DIR"
else
    echo "[stow] Error: stow-dotfiles directory not found in $SCRIPT_DIR"
fi

# Set LANG if not already set
BASHRC="$HOME/.bashrc"
if [ -z "$LANG" ]; then
    echo "[bash] Setting LANG=en_US.UTF-8 in $BASHRC..."
    if ! grep -q "export LANG=en_US.UTF-8" "$BASHRC" 2>/dev/null; then
        echo "export LANG=en_US.UTF-8" >> "$BASHRC"
        echo "[bash] LANG set in $BASHRC."
    else
        echo "[bash] LANG already configured in $BASHRC."
    fi
    export LANG=en_US.UTF-8
fi

# Setup Fish Shell
echo "[fish] Setting up Fish shell..."
echo "[fish] Fish version: $(fish --version)"

# Install Fisher and plugins.
# PatrickF1/fzf.fish uses `set -f` (function-local scope) which was added in
# fish 3.5; on older fish (e.g. Debian buster ships 3.1.2) the plugin emits
# errors on every shell start. Skip the install there — config.fish already
# falls back to the native `fzf --fish | source` integration.
FISH_VER=$(fish -c 'echo $version' 2>/dev/null)
FISH_MAJOR=${FISH_VER%%.*}
FISH_MINOR=$(echo "$FISH_VER" | cut -d. -f2)
if [ "${FISH_MAJOR:-0}" -gt 3 ] || { [ "${FISH_MAJOR:-0}" -eq 3 ] && [ "${FISH_MINOR:-0}" -ge 5 ]; }; then
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install PatrickF1/fzf.fish'
else
    echo "[fish] Skipping fisher/fzf.fish install: fish $FISH_VER is too old (need >= 3.5). Native 'fzf --fish | source' in config.fish covers fzf integration."
fi

# Configure .bashrc to start fish automatically (from README.md)
echo "[bash] Configuring .bashrc to automatically start fish..."
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
        echo "[bash] Updated $BASHRC to launch fish."
    else
        echo "[bash] Fish launch logic already in $BASHRC."
    fi
fi

echo "==================================================="
echo "[setup] Setup complete!"
echo "[setup] Please restart your shell or log out and back in."
echo "[setup] Fish has been configured to launch automatically from .bashrc."
echo "==================================================="
