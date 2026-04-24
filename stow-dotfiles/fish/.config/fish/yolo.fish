# Bash wrapper:
#   yolo() {
#     fish -c 'source ~/.config/fish/yolo.fish; yolo $argv' -- "$@"
#   }

function _yolo_print_cmd --description "Pretty-print a command with one flag per line"
    set -l line "+ $argv[1]"
    set -l i 2
    while test $i -le (count $argv)
        set -l arg $argv[$i]
        if test "$arg" = --
            echo "  $line \\" >&2
            echo "    --" $argv[(math $i + 1)..-1] >&2
            return
        end
        if string match -q -- '--*' $arg
            echo "  $line \\" >&2
            set line "    $arg"
            while test (math $i + 1) -le (count $argv); and not string match -q -- '--*' $argv[(math $i + 1)]
                set i (math $i + 1)
                set line "$line $argv[$i]"
            end
        else
            set line "$line $arg"
        end
        set i (math $i + 1)
    end
    echo "  $line" >&2
end

function _yolo_get_git_worktree_dir --description "Return git common dir if in a worktree with external git directory"
    if not command -q git
        return
    end
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        return
    end
    set -l git_dir (git rev-parse --git-common-dir 2>/dev/null)
    set -l workdir (pwd -P)
    if test -n "$git_dir"; and test -d "$git_dir"; and not string match -q "$workdir/*" "$git_dir"
        echo "$git_dir"
    end
end

function _yolo_bwrap --description "Run command in bwrap sandbox"
    # argv: ro_paths... -- rw_paths... -- command_args...
    set -l ro_paths
    set -l rw_paths
    set -l command_args
    set -l section ro
    for arg in $argv
        if test "$arg" = --
            if test $section = ro
                set section rw
            else
                set section cmd
            end
            continue
        end
        switch $section
            case ro
                set -a ro_paths $arg
            case rw
                set -a rw_paths $arg
            case cmd
                set -a command_args $arg
        end
    end

    set -l workdir (pwd -P)
    set -l sys_prefixes /usr /bin /lib /lib64 /etc

    set -l bwrap_args \
        --clearenv \
        --proc /proc \
        --dev /dev \
        --tmpfs /tmp \
        --unshare-all \
        --share-net \
        --die-with-parent

    # Dotfile
    if test -d $HOME/dotfiles
        set -a bwrap_args --ro-bind $HOME/dotfiles $HOME/dotfiles
    end

    # X11 display socket (must come after --tmpfs /tmp)
    if test -d /tmp/.X11-unix
        set -a bwrap_args --ro-bind /tmp/.X11-unix /tmp/.X11-unix
    end

    # Claude Code tmpdir (rw, must come after --tmpfs /tmp)
    if test -d /tmp/claude-(id -u)
        set -a bwrap_args --bind /tmp/claude-(id -u) /tmp/claude-(id -u)
    end

    # Wayland display socket
    if set -q WAYLAND_DISPLAY; and set -q XDG_RUNTIME_DIR; and test -e "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
        set -a bwrap_args --ro-bind "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    end

    set -l ro_seen

    # Helper: add ro-bind if path exists and not seen
    # (inlined as a function would not see our local variables)
    function _bwrap_ro --no-scope-shadowing
        for p in $argv
            if test -e $p; and not contains -- $p $ro_seen
                set -a ro_seen $p
                set -a bwrap_args --ro-bind $p $p
            end
        end
    end

    # System mounts (ro)
    _bwrap_ro $sys_prefixes

    # DNS resolver runtime mounts
    if test -e /etc/resolv.conf
        set -l resolv_source (readlink -f -- /etc/resolv.conf)
        if test -n "$resolv_source"; and string match -q '/run/*' $resolv_source
            set -l runtime_dir (dirname -- $resolv_source)
            set -l current /run
            set -a bwrap_args --dir $current
            for component in (string split '/' (string replace '/run/' '' $runtime_dir))
                set current $current/$component
                set -a bwrap_args --dir $current
            end
            _bwrap_ro $runtime_dir
        end
    end

    # Command and extra ro paths
    set -l home_prefixes $HOME/.npm $HOME/.cargo $HOME/.local
    for candidate in $ro_paths
        set -l skip false
        for prefix in $sys_prefixes
            if test $candidate = $prefix; or string match -q "$prefix/*" $candidate
                set skip true
                break
            end
        end
        test $skip = true; and continue
        if test $candidate = $workdir; or string match -q "$workdir/*" $candidate
            continue
        end
        set -l matched false
        for prefix in $home_prefixes
            if test -e $prefix; and string match -q "$prefix/*" $candidate
                _bwrap_ro $prefix
                set matched true
                break
            end
        end
        if test $matched = false
            _bwrap_ro (dirname -- $candidate)
        end
    end

    # Git/SSH state (ro)
    _bwrap_ro $HOME/.gitconfig $HOME/.git-credentials $HOME/.config/git $HOME/.ssh

    # X auth cookie (ro)
    if set -q XAUTHORITY; and test -e "$XAUTHORITY"
        _bwrap_ro $XAUTHORITY
    end

    # Working directory (rw)
    if test -e $workdir
        set -a bwrap_args --bind $workdir $workdir
    end

    # If current directory is in a git worktree, also bind the actual git repo directory
    set -l git_worktree_dir (_yolo_get_git_worktree_dir)
    if test -n "$git_worktree_dir"
        set -a bwrap_args --bind "$git_worktree_dir" "$git_worktree_dir"
    end

    # Cache + extra rw paths
    if test -e $HOME/.cache
        set -a bwrap_args --bind $HOME/.cache $HOME/.cache
    end
    for p in $rw_paths
        if test -e $p
            set -a bwrap_args --bind $p $p
        end
    end

    # Environment
    set -a bwrap_args \
        --chdir $workdir \
        --setenv HOME $HOME \
        --setenv PATH (string join ':' $PATH) \
        --setenv PWD $workdir

    # bwrap user namespace maps only our UID; root-owned files appear as
    # nobody:nobody inside the sandbox.  SSH rejects included config files
    # not owned by root or the current user, so /etc/ssh/ssh_config.d/*.conf
    # fails.  Skip system ssh_config to avoid the ownership check.
    if not set -q GIT_SSH_COMMAND
        set -a bwrap_args --setenv GIT_SSH_COMMAND "ssh -F /dev/null"
    end

    for env_name in \
        DISPLAY WAYLAND_DISPLAY XAUTHORITY XDG_RUNTIME_DIR \
        TERM COLORTERM LANG LC_ALL NO_COLOR \
        HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY \
        http_proxy https_proxy all_proxy no_proxy \
        GIT_SSH_COMMAND
        if set -q $env_name
            set -a bwrap_args --setenv $env_name $$env_name
        end
    end

    # Extra env variables from --setenv flags
    for env_name in $_yolo_extra_env
        if set -q $env_name
            set -a bwrap_args --setenv $env_name $$env_name
        end
    end

    # Env variables loaded from .env.toml via --loadenv
    set -l li 1
    while test $li -le (count $_yolo_loaded_env_names)
        set -a bwrap_args --setenv $_yolo_loaded_env_names[$li] $_yolo_loaded_env_values[$li]
        set li (math $li + 1)
    end

    functions -e _bwrap_ro
    _yolo_print_cmd bwrap $bwrap_args -- $command_args
    bwrap $bwrap_args $command_args
end

function _yolo_sandbox_exec --description "Run command in macOS sandbox-exec"
    # argv: ro_paths... -- rw_paths... -- command_args...
    set -l ro_paths
    set -l rw_paths
    set -l command_args
    set -l section ro
    for arg in $argv
        if test "$arg" = --
            if test $section = ro
                set section rw
            else
                set section cmd
            end
            continue
        end
        switch $section
            case ro
                set -a ro_paths $arg
            case rw
                set -a rw_paths $arg
            case cmd
                set -a command_args $arg
        end
    end

    set -l workdir (pwd -P)

    # Build SBPL profile
    # Allow all reads; sandbox restricts writes to workdir, cache, tmp, and tool state.
    set -l profile "(version 1)
(deny default)
(allow network*)
(allow process*)
(allow sysctl-read)
(allow mach*)
(allow ipc-posix-shm*)
(allow signal)
(allow file-read*)
(allow file-ioctl)
(allow file-write* (subpath \"/dev\"))
(allow file-write* (subpath \"/tmp\"))
(allow file-write* (subpath \"/private/tmp\"))
(allow file-write* (subpath \"/private/var/folders\"))
(allow file-write* (subpath \"/Users/bytedance/Library/Application Support/lark-cli\"))
(allow file-write* (subpath \"/Users/bytedance/.lark-cli/\"))

; Working directory (rw)
(allow file-write* (subpath \"$workdir\"))"

    # If current directory is in a git worktree, also allow access to the actual git repo directory
    set -l git_worktree_dir (_yolo_get_git_worktree_dir)
    if test -n "$git_worktree_dir"
        set profile "$profile
(allow file-write* (subpath \"$git_worktree_dir\"))"
    end

    set profile "$profile
; Cache (rw)
(allow file-write* (subpath \"$HOME/.cache\"))"

    # Extra rw paths (tool state)
    for p in $rw_paths
        if test -e $p
            if test -d $p
                set profile "$profile
(allow file-write* (subpath \"$p\"))"
            else
                set profile "$profile
(allow file-write* (literal \"$p\"))"
            end
        end
    end

    # Set loaded env vars for sandbox-exec (inherits parent env)
    set -l li 1
    while test $li -le (count $_yolo_loaded_env_names)
        set -gx $_yolo_loaded_env_names[$li] $_yolo_loaded_env_values[$li]
        set li (math $li + 1)
    end

    echo "+ sandbox-exec -p '$profile'" $command_args >&2
    sandbox-exec -p $profile $command_args
    set -l sandbox_ret $status

    # Clean up loaded env vars
    for env_name in $_yolo_loaded_env_names
        set -e $env_name
    end
    return $sandbox_ret
end

function _yolo_load_env_group --description "Parse .env.toml and return KEY=VALUE pairs for a group"
    # argv[1] = toml file path, argv[2] = group name
    set -l toml_file $argv[1]
    set -l group $argv[2]
    if not test -f "$toml_file"
        echo "yolo: env file not found: $toml_file" >&2
        return 1
    end
    set -l in_group false
    while read -l line
        # Strip leading/trailing whitespace
        set line (string trim -- "$line")
        # Skip empty lines and comments
        if test -z "$line"; or string match -q '#*' "$line"
            continue
        end
        # Check for section header
        if string match -rq '^\[(.+)\]$' "$line"
            set -l section (string match -r '^\[(.+)\]$' "$line")[2]
            if test "$section" = "$group"
                set in_group true
            else if $in_group
                # Left our section, stop
                break
            end
            continue
        end
        if $in_group
            # Parse KEY = "VALUE" or KEY = 'VALUE' or KEY = VALUE
            if string match -rq '^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"(.*)"$' "$line"
                set -l m (string match -r '^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"(.*)"$' "$line")
                echo "$m[2]=$m[3]"
            else if string match -rq "^([A-Za-z_][A-Za-z0-9_]*)\\s*=\\s*'(.*)'\\s*\$" "$line"
                set -l m (string match -r "^([A-Za-z_][A-Za-z0-9_]*)\\s*=\\s*'(.*)'" "$line")
                echo "$m[2]=$m[3]"
            else if string match -rq '^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$' "$line"
                set -l m (string match -r '^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$' "$line")
                echo "$m[2]=$m[3]"
            end
        end
    end <"$toml_file"
end

function yolo --description "Run a command in a sandbox"
    # Parse yolo's own flags
    set -l extra_env_names
    set -l loaded_env_names
    set -l loaded_env_values
    set -l positional
    set -l i 1
    set -l env_file (dirname (status filename))/.env.toml
    while test $i -le (count $argv)
        switch $argv[$i]
            case --help -h
                echo "usage: yolo [options] <command> [args...]" >&2
                echo >&2
                echo "Run a command inside a sandboxed environment (bwrap on Linux, sandbox-exec on macOS)." >&2
                echo >&2
                echo "Options:" >&2
                echo "  --help, -h          Show this help message" >&2
                echo "  --setenv NAME       Pass environment variable NAME into the sandbox" >&2
                echo "                      (can be specified multiple times)" >&2
                echo "  --loadenv GROUP     Load env variables from .env.toml under [GROUP]" >&2
                echo "                      (can be specified multiple times)" >&2
                echo >&2
                echo "Environment file: $env_file" >&2
                echo >&2
                echo "Examples:" >&2
                echo "  yolo claude" >&2
                echo "  yolo --setenv MY_TOKEN --setenv DEBUG claude --print" >&2
                echo "  yolo --loadenv openai claude" >&2
                return 0
            case --setenv
                set i (math $i + 1)
                if test $i -gt (count $argv)
                    echo "yolo: --setenv requires an argument" >&2
                    return 1
                end
                set -a extra_env_names $argv[$i]
            case --loadenv
                set i (math $i + 1)
                if test $i -gt (count $argv)
                    echo "yolo: --loadenv requires a group name" >&2
                    return 1
                end
                set -l group $argv[$i]
                set -l pairs (_yolo_load_env_group "$env_file" "$group")
                if test $status -ne 0
                    return 1
                end
                if test (count $pairs) -eq 0
                    echo "yolo: no env variables found in group [$group]" >&2
                    return 1
                end
                for pair in $pairs
                    set -l kv (string split -m 1 '=' "$pair")
                    set -a loaded_env_names $kv[1]
                    set -a loaded_env_values $kv[2]
                end
            case '*'
                # First non-flag argument starts the command; collect the rest as-is
                set positional $argv[$i..-1]
                break
        end
        set i (math $i + 1)
    end

    if test (count $positional) -eq 0
        echo "usage: yolo [options] <command> [args...]" >&2
        return 1
    end

    set -l original_command $positional[1]
    set -l argv $positional[2..-1]

    # Resolve command path
    set -l original_path
    if string match -q '*/*' $original_command
        set original_path (cd -- (dirname -- $original_command) && pwd -P)"/"(basename -- $original_command)
    else
        set original_path (command -s $original_command)
    end
    if test -z "$original_path"
        echo "command not found: $original_command" >&2
        return 1
    end
    if not test -f $original_path
        echo "not a file: $original_path" >&2
        return 1
    end
    if not test -x $original_path
        echo "not executable: $original_path" >&2
        return 1
    end

    set -l real_path (readlink -f -- $original_path)
    set -l tool_name (basename -- $original_path)

    # Collect ro paths (command binary and its resolved path)
    set -l ro_paths $original_path $real_path

    # Collect rw paths (tool-specific state)
    set -l rw_paths
    switch $tool_name
        case claude
            for p in $HOME/.claude $HOME/.claude.json
                if test -e $p
                    set -a rw_paths $p
                end
            end
        case codex
            for p in $HOME/.codex
                if test -e $p
                    set -a rw_paths $p
                end
            end
    end

    # Build command with tool-specific flags
    set -l command_args $original_path
    switch $tool_name
        case codex
            set -a command_args --dangerously-bypass-approvals-and-sandbox
        case claude
            set -l joined_argv (string join -- ' ' $argv)
            set -a command_args --permission-mode bypassPermissions
    end
    set -a command_args $argv

    # Export extra env for sandbox backends
    set -g _yolo_extra_env $extra_env_names
    set -g _yolo_loaded_env_names $loaded_env_names
    set -g _yolo_loaded_env_values $loaded_env_values

    # Dispatch to OS-specific backend
    set -l os (uname -s)
    switch $os
        case Linux
            if not command -q bwrap
                echo "bwrap is not installed or not on PATH" >&2
                set -e _yolo_extra_env
                set -e _yolo_loaded_env_names
                set -e _yolo_loaded_env_values
                return 1
            end
            _yolo_bwrap $ro_paths -- $rw_paths -- $command_args
        case Darwin
            if not command -q sandbox-exec
                echo "sandbox-exec is not available" >&2
                set -e _yolo_extra_env
                set -e _yolo_loaded_env_names
                set -e _yolo_loaded_env_values
                return 1
            end
            _yolo_sandbox_exec $ro_paths -- $rw_paths -- $command_args
        case '*'
            echo "unsupported OS: $os" >&2
            set -e _yolo_extra_env
            set -e _yolo_loaded_env_names
            set -e _yolo_loaded_env_values
            return 1
    end
    set -l ret $status
    set -e _yolo_extra_env
    set -e _yolo_loaded_env_names
    set -e _yolo_loaded_env_values
    return $ret
end
