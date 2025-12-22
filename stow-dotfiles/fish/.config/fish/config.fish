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
		set -x PATH $HOME/.cargo/bin $PATH
	end
	if not string match -q -r "/usr/local/texlive/2024/bin/x86_64-linux" $PATH
		if test -d /usr/local/texlive/2024/bin/x86_64-linux
			set -x PATH /usr/local/texlive/2024/bin/x86_64-linux $PATH
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

	if command -q zoxide
		zoxide init fish | source
	end

	if command -q yazi
		# Then use y instead of yazi to start, and press q to quit, you'll see the CWD changed.
		# Sometimes, if you don't want to change, press Q to quit.
		function y
			set tmp (mktemp -t "yazi-cwd.XXXXXX")
			yazi $argv --cwd-file="$tmp"
			if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
				builtin cd -- "$cwd"
			end
			rm -f -- "$tmp"
		end
	end

	if command -q yazi
		function icat
			kitten icat $argv
		end
	end

	function proxy-for --description "Run command with local proxy settings"
		set -lx HTTP_PROXY "http://127.0.0.1:7890"
		set -lx HTTPS_PROXY "http://127.0.0.1:7890"
		set -lx ALL_PROXY "http://127.0.0.1:7890"
		set -lx NO_PROXY "localhost,127.0.0.1,::1"
		$argv
	end
end
