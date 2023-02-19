#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

PROXY_ENV="http_proxy ftp_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY"

assignProxy(){
	for envar in $PROXY_ENV
	do
		export $envar=$1
	done
	for envar in "no_proxy NO_PROXY"
	do
		export $envar=$2
	done
}

proxyoff(){
	for envar in $PROXY_ENV
	do
		unset $envar
	done
}

proxyon(){
	# user=YourUserName
	# read -p "Password: " -s pass &&  echo -e " "
	# proxy_value="http://$user:$pass@ProxyServerAddress:Port"

	# Don't use locahost, which can be resolved into an Ipv6 address
	proxy_value="http://127.0.0.1:7890"
	no_proxy_value="localhost,127.0.0.1,LocalAddress,LocalDomain.com"
	assignProxy $proxy_value $no_proxy_value
}

ranger_nonested() {
	if [ -z "$RANGER_LEVEL" ]; then
		/usr/bin/ranger "$@"
	else
		exit
	fi
}

# alias

alias ls='ls --color=auto'
alias ra='ranger_nonested'
alias ..='cd ..'
alias ...='cd ../..'

# Execute scripts

export PATH=$PATH:/home/chengke/.local/bin

# Plugins

function source_if_exists() {
	local file
	file="$1"
	[[ -f "$file" ]] && source "$file"
}

source_if_exists /usr/share/fzf/key-bindings.bash
source_if_exists /etc/profile.d/autojump.sh
source_if_exists /etc/profile

if [ ! -z "$(command -v zoxide)" ]; then 
	eval "$(zoxide init bash)"
fi
