FROM ubuntu:23.04

RUN apt-get update && apt-get install -y \
	adduser \
	bat \
	cmake \
	curl \
	dumb-init \
	fd-find \
	fish \
	fzf \
	gcc \
	git \
	make \
	nodejs \
	npm \
	python3 \
	python3-pynvim \
	ranger \
	ripgrep \
	stow \
	sudo \
	ssh \
	tmux \
	unzip \
	uuid-runtime \
	&& rm -rf /var/lib/apt/lists/* && \
	chsh -s /usr/bin/fish ubuntu && \
	addgroup wheel && adduser ubuntu wheel && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/wheel

USER ubuntu
WORKDIR /work
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["fish"]

COPY --chown=ubuntu:ubuntu ./stow-dotfiles /home/ubuntu/.dotfiles
RUN cd /home/ubuntu/.dotfiles && stow -t /home/ubuntu -R *

RUN fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install PatrickF1/fzf.fish'

# The "sleep *" is a workaround for https://github.com/nvim-treesitter/nvim-treesitter/issues/2900
RUN curl -L https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz | sudo tar zxf - -C /usr/local/ --strip-components=1 && \
	nvim --headless +"Lazy restore" +"TSUpdateSync" +"MasonUpdate" \
	+"MasonInstall pyright" +"MasonInstall black" +"MasonInstall clangd" \
	+"sleep 20" +qall

