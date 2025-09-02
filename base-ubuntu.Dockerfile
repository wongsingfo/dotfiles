FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
	7zip \
	adduser \
	bat \
	cmake \
	curl \
	dumb-init \
	fd-find \
	fish \
	fzf \
	gcc \
	g++ \
	git \
	iproute2 \
	jq \
	make \
	python3 \
	python3-pynvim \
	python3-venv \
	ripgrep \
	rsync \
	stow \
	sudo \
	ssh \
	sshpass \
	tmux \
	unzip \
	uuid-runtime \
	zoxide \
	&& rm -rf /var/lib/apt/lists/* && \
	chsh -s /usr/bin/fish ubuntu && \
	addgroup wheel && adduser ubuntu wheel && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/wheel

RUN sudo curl -s https://nodejs.org/dist/v24.4.0/node-v24.4.0-linux-x64.tar.xz | sudo tar -xJ --strip-components=1 -C /usr/local && npm install -g trzsz @anthropic-ai/claude-code @musistudio/claude-code-router

# Install yazi
RUN sh -c 'TEMP_DIR=$(mktemp -d); echo "$TEMP_DIR"; \
ZIP_FILE="$TEMP_DIR/yazi.zip"; \
curl -L https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-musl.zip -o "$ZIP_FILE" && \
unzip "$ZIP_FILE" -d "$TEMP_DIR" && \
cp "${TEMP_DIR}/yazi-x86_64-unknown-linux-musl/ya" /usr/local/bin/ && \
cp "${TEMP_DIR}/yazi-x86_64-unknown-linux-musl/yazi" /usr/local/bin/ && \
rm -rf "$TEMP_DIR"'

USER ubuntu
WORKDIR /work
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["fish"]

COPY --chown=ubuntu:ubuntu ./stow-dotfiles /home/ubuntu/.dotfiles
RUN cd /home/ubuntu/.dotfiles && stow -t /home/ubuntu -R *

RUN fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install PatrickF1/fzf.fish'

RUN curl -L https://github.com/neovim/neovim-releases/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz | sudo tar zxf - -C /usr/local/ --strip-components=1

RUN curl -LsSf https://astral.sh/uv/install.sh | sh && /home/ubuntu/.local/bin/uv tool install llm && /home/ubuntu/.local/bin/llm install llm-openrouter

