FROM wongsingfo/dotfiles:amd64

RUN { curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh /dev/stdin -y ; } && \
	nvim --headless +"MasonInstall rust-analyzer" +qall
