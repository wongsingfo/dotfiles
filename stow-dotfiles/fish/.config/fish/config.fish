set -x EDITOR nvim
set -x SHELL fish
set -x PAGER less

set -x PATH $HOME/.local/bin $PATH
set -gx MAMBA_EXE "$HOME/.local/bin/micromamba"
set -gx MAMBA_ROOT_PREFIX "$HOME/micromamba"

if test -f $MAMBA_EXE
	$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
	$MAMBA_EXE shell activate | source
end

# Check if $HOME/.cargo/bin is in $PATH
if not string match -q -r "$HOME/.cargo/bin" $PATH
	# If it's not in $PATH, add it
	set -x PATH $PATH $HOME/.cargo/bin
end

if status is-interactive
	function gpt --wraps=bash
		bash ~/dotfiles/chatgpt.sh $argv
	end

	# set -x TERM screen-256color
	if test "$TERM" = "xterm"
		set -x TERM "xterm-256color"
	end

	if command -q fzf
		fzf --fish | source
	end
end
