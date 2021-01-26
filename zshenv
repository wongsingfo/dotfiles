# Used for setting environment variables for all users; it should not contain
# commands that produce output or assume the shell is attached to a TTY. When
# this file exists it will always be read, this cannot be overridden.

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

