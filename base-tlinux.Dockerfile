FROM mirrors.tencent.com/tlinux/tlinux3.3

# Install required packages
RUN dnf install -y \
cmake \
curl \
dumb-init \
fd-find \
fzf \
gcc \
git \
make \
nodejs \
npm \
openssh-clients \
python39 \
ripgrep \
rsync \
sshpass \
stow \
tmux \
unzip \
which \
&& dnf clean all && \
npm install -g trzsz neovim

WORKDIR /data/chengke
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["fish"]

COPY ./stow-dotfiles /root/.dotfiles
RUN cd /root/.dotfiles && stow -t /root -R *

# Install and setup fish
RUN curl -L https://github.com/fish-shell/fish-shell/releases/download/4.0.2/fish-static-amd64-4.0.2.tar.xz | tar -xJvC /usr/bin && \
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install PatrickF1/fzf.fish'

# Install yazi
RUN sh -c 'TEMP_DIR=$(mktemp -d); echo "$TEMP_DIR"; \
ZIP_FILE="$TEMP_DIR/yazi.zip"; \
curl -L https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-musl.zip -o "$ZIP_FILE" && \
unzip "$ZIP_FILE" -d "$TEMP_DIR" && \
cp "${TEMP_DIR}/yazi-x86_64-unknown-linux-musl/ya" /usr/local/bin/ && \
cp "${TEMP_DIR}/yazi-x86_64-unknown-linux-musl/yazi" /usr/local/bin/ && \
rm -rf "$TEMP_DIR"'

# Install Neovim and required tools
RUN curl -L https://github.com/neovim/neovim-releases/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz | tar zxf - -C /usr/local/ --strip-components=1
# nvim --headless +"Lazy restore" +"TSUpdateSync" +"Mason" +"MasonInstall pyright" +"MasonInstall black" +"MasonInstall clangd" \
