set -x SHELL (which fish)

if command -q less
	set -x PAGER less
end

if command -q nvim
	set -x EDITOR nvim
else if command -q vim
	set -x EDITOR vim
end

function update_path
	# Add .local/bin
	if not string match -q -r "$HOME/.local/bin" $PATH
		set -x PATH $HOME/.local/bin $PATH
	end
	# Check if $HOME/.cargo/bin is in $PATH
	if not string match -q -r "$HOME/.cargo/bin" $PATH
		# If it's not in $PATH, add it
		set -x PATH $PATH $HOME/.cargo/bin
	end
	if not string match -q -r "/usr/local/texlive/2024/bin/x86_64-linux" $PATH
		if test -d /usr/local/texlive/2024/bin/x86_64-linux
			set -x PATH $PATH /usr/local/texlive/2024/bin/x86_64-linux
		end
	end
end
update_path

set -gx MAMBA_EXE "$HOME/.local/bin/micromamba"
set -gx MAMBA_ROOT_PREFIX "$HOME/micromamba"

if test -f $MAMBA_EXE
	$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
	$MAMBA_EXE shell activate | source
end

if command -q go
	set -x GOPROXY https://goproxy.cn
end

# This overrides the prompt set by MAMBA_EXE
fish_config prompt choose scales

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
