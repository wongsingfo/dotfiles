set -x EDITOR nvim
set -x SHELL fish
set -x PAGER less

# Not a good idea to set this.
# see: https://superuser.com/questions/424086/what-is-the-difference-between-screen-256-color-and-xterm-256color
# set -x TERM screen-256color

if type -q fzf_configure_bindings
	fzf_configure_bindings --directory=\co
end
