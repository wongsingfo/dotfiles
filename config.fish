if status is-interactive
    # Commands to run in interactive sessions can go here
    set -U fish_user_paths ~/.local/bin/ $fish_user_paths
    alias proxyon 'export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890'

    if test -n "$SSH_CONNECTION" -a -z "$TMUX"
        tmux attach-session -t default || tmux new-session -s default
    end
end
