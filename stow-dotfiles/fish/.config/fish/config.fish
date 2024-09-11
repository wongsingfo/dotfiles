set -x SHELL fish

if command -q less
	set -x PAGER less
end

if command -q nvim
    set -x EDITOR nvim
else if command -q vim
    set -x EDITOR vim
end

set -x PATH $HOME/.local/bin $PATH
set -gx MAMBA_EXE "$HOME/.local/bin/micromamba"
set -gx MAMBA_ROOT_PREFIX "$HOME/micromamba"

if test -f $MAMBA_EXE
	$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
	$MAMBA_EXE shell activate | source
end

# WARN: this override the prompt set by MAMBA_EXE
fish_config prompt choose scales

# Check if $HOME/.cargo/bin is in $PATH
if not string match -q -r "$HOME/.cargo/bin" $PATH
	# If it's not in $PATH, add it
	set -x PATH $PATH $HOME/.cargo/bin
end

set -x GPT_SHELL "$HOME/dotfiles/chatgpt.sh"
if test -f $GPT_SHELL
	function gpt --wraps=bash
		bash $GPT_SHELL $argv
	end
end

if status is-interactive
	# set -x TERM screen-256color
	if test "$TERM" = "xterm"
		set -x TERM "xterm-256color"
	end

	if command -q fzf
		fzf --fish | source
	end
end
