# Used for setting environment variables for all users; it should not contain
# commands that produce output or assume the shell is attached to a TTY. When
# this file exists it will always be read, this cannot be overridden.

# Rust cargo
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
# scripts installed by pip
[ -d "$HOME/.local/bin" ] && export PATH="${PATH}:$HOME/.local/bin"
# texlive
[ -e "/usr/local/texlive/2021/bin/x86_64-linux" ] && export PATH=/usr/local/texlive/2021/bin/x86_64-linux:$PATH
# Node version manager (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"

