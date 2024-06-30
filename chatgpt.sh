#!/usr/bin/env bash

set -e
set -o pipefail

# API_HOST=https://api.openai.com
# API_HOST=https://api.anthropic.com
API_HOST=api.gptsapi.net
OPENAI_API_KEY=$(cat $HOME/.config/WILDCARD_KEY)
TMP_FILE=/tmp/chatgpt-input.txt

PROMPT_COMMAND_GENERATION="You are a Command Line Interface expert and your
task is to provide functioning shell commands. Return a CLI command and nothing
else - do not send it in a code block, quotes, or anything else, just the pure
text CONTAINING ONLY THE COMMAND. If possible, return a one-line bash
command or chain many commands together. Return ONLY the command ready
to run in the terminal. The command should do the following:"

if [ $# -eq 0 ]; then
    echo "Usage: $0 [--attach file] [--cli] prompt_text"
    exit 1
fi

attachment=""
cli_mode=""

while [ "$1" != "" ]; do
    case $1 in
        --attach )
            shift
            attachment=$1
            ;;
	--cli )
	    cli_mode=1
	    ;;
        * )
            prompt=$1
            ;;
    esac
    shift
done

function make_input_cli() {
	local content="$1"
	cat >$TMP_FILE <<EOF
{
"model": "gpt-3.5-turbo",
"stream": true,
"messages": [
{
	"role": "system",
	"content": "$PROMPT_COMMAND_GENERATION"
},
{
	"role": "user",
	"content": "$content"
}
]
}
EOF
}

function make_input_once() {
	local content="$1"
	cat >$TMP_FILE <<EOF
{
"model": "gpt-3.5-turbo",
"stream": true,
"messages": [
{
	"role": "user",
	"content": "$content"
}
]
}
EOF
}

function make_input_with_attachment() {
	local content="$1"
	local attachment="$2"
	cat >$TMP_FILE <<EOF
{
"model": "gpt-3.5-turbo",
"stream": true,
"messages": [
{
	"role": "system",
	"content": "$content"
},
{
	"role": "user",
	"content":
EOF
	jq --raw-input --slurp <"$attachment" >>$TMP_FILE
	cat >>$TMP_FILE <<"EOF"
}
]
}
EOF
}

function make_request() {
	curl --fail --header "Authorization: Bearer $OPENAI_API_KEY" \
	  --header 'Content-Type: application/json' \
	  --data "@$TMP_FILE" -N -s "https://${API_HOST}/v1/chat/completions" |
	  awk -F 'data: ' '{print $2; fflush()}' |
	  jq --unbuffered -R -j 'fromjson? | (.choices[].delta.content)? | select(. != null)'
	# Add a newline at the end
	echo
}

if [ -n "$cli_mode" ]; then
	make_input_cli "$prompt"
	cmd=$(make_request)
	echo "$cmd"
	read -p "Do you want to continue? (Y/n): " response
	response=${response:-Y}
	if [[ "$response" =~ ^[Yy]$ ]]; then
		eval "$cmd"
	else
		"Abort"
	fi
	exit
fi

if [ -z "$attachment" ]; then
	make_input_once "$prompt"
else
	make_input_with_attachment "$prompt" "$attachment"
fi
# cat $TMP_FILE
make_request
