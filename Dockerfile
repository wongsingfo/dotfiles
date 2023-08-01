FROM alpine:latest

ARG USER_ID=1000

RUN apk upgrade --no-cache && apk add --no-cache \
	bash \
	bat \
	clang \
	clang-extra-tools \
	cmake \
	curl \
	fd \
	file \
	fish \
	fzf \
	g++ \
	gcc \
	gdb \
	git \
	make \
	mandoc \
	man-pages \
	man-pages-posix \
	neovim \
	nodejs \
	npm \
	py3-pip \
	python3 \
	ranger \
	stow \
	sudo \
	tmux \
	util-linux \
	wget

RUN echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel && \
	adduser -D user -s /usr/bin/fish -u $USER_ID -g $USER_ID && \
	addgroup user wheel

USER user
WORKDIR /work
CMD ["fish"]

COPY --chown=user:user ./stow-dotfiles /home/user/.dotfiles
RUN cd /home/user/.dotfiles && \
	stow -t /home/user -R *

# RUN curl https://hishtory.dev/install.py | python3 -

RUN fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install PatrickF1/fzf.fish'

# The "sleep 10" is a workaround for https://github.com/nvim-treesitter/nvim-treesitter/issues/2900
RUN sudo npm install -g neovim && \
	pip install neovim && \
	nvim --headless +"Lazy sync" +TSUpdateSync +"MasonUpdate" +"MasonInstall pyright" +"sleep 10" +qall

