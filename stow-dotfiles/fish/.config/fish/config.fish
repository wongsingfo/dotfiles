set -x EDITOR nvim
set -x SHELL fish
set -x PAGER less

# set -x TERM screen-256color
if test "$TERM" = "xterm"
    set -x TERM "xterm-256color"
end

if type -q fzf_configure_bindings
	fzf_configure_bindings --directory=\co
end

# Check if $HOME/.cargo/bin is in $PATH
if not string match -q -r "$HOME/.cargo/bin" $PATH
    # If it's not in $PATH, add it
    set -x PATH $PATH $HOME/.cargo/bin
end
