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

function _yolo_bind --description "Add bind if path exists and not already seen"
    # argv[1] = seen-list var name, argv[2] = bwrap-args var name
    # argv[3] = --ro-bind or --bind, argv[4..] = paths
    set -l seen_var $argv[1]
    set -l args_var $argv[2]
    set -l bind_type $argv[3]
    for p in $argv[4..-1]
        if test -e $p; and not contains -- $p $$seen_var
            set -a $seen_var $p
            set -a $args_var $bind_type $p $p
        end
    end
end

function _yolo_mount_resolv --description "Mount DNS resolver runtime dirs"
    # argv[1] = bwrap-args var name, argv[2] = ro-seen var name
    set -l args_var $argv[1]
    set -l seen_var $argv[2]
    test -e /etc/resolv.conf; or return
    set -l resolv_source (readlink -f -- /etc/resolv.conf)
    test -n "$resolv_source"; and string match -q '/run/*' $resolv_source; or return

    set -l runtime_dir (dirname -- $resolv_source)
    set -l current /run
    set -a $args_var --dir $current
    for component in (string split '/' (string replace '/run/' '' $runtime_dir))
        set current $current/$component
        set -a $args_var --dir $current
    end
    if test -e $runtime_dir; and not contains -- $runtime_dir $$seen_var
        set -a $seen_var $runtime_dir
        set -a $args_var --ro-bind $runtime_dir $runtime_dir
    end
end

function yolo --description "Run a command in a bwrap sandbox"
    if not command -q bwrap
        echo "bwrap is not installed or not on PATH" >&2
        return 1
    end
    if test (count $argv) -eq 0
        echo "usage: yolo <command> [args...]" >&2
        return 1
    end

    set -l workdir (pwd -P)
    set -l original_command $argv[1]
    set -e argv[1]

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
    set -l sys_prefixes /usr /bin /lib /lib64 /etc

    set -l bwrap_args \
        --clearenv \
        --proc /proc \
        --dev /dev \
        --tmpfs /tmp \
        --unshare-all \
        --share-net \
        --die-with-parent

    set -l ro_seen

    # System mounts (ro)
    _yolo_bind ro_seen bwrap_args --ro-bind $sys_prefixes

    # DNS resolver runtime mounts
    _yolo_mount_resolv bwrap_args ro_seen

    # Mount command paths (ro)
    set -l home_prefixes $HOME/.npm $HOME/.cargo $HOME/.local
    for candidate in $original_path $real_path
        # Skip if under a system prefix (already mounted)
        set -l skip false
        for prefix in $sys_prefixes
            if test $candidate = $prefix; or string match -q "$prefix/*" $candidate
                set skip true
                break
            end
        end
        test $skip = true; and continue

        # Skip if under workdir (will be rw-mounted)
        if test $candidate = $workdir; or string match -q "$workdir/*" $candidate
            continue
        end

        # Try known home prefixes first, else mount parent dir
        set -l matched false
        for prefix in $home_prefixes
            if test -e $prefix; and string match -q "$prefix/*" $candidate
                _yolo_bind ro_seen bwrap_args --ro-bind $prefix
                set matched true
                break
            end
        end
        if test $matched = false
            set -l parent (dirname -- $candidate)
            _yolo_bind ro_seen bwrap_args --ro-bind $parent
        end
    end

    # Working directory (rw)
    if test -e $workdir
        set -a bwrap_args --bind $workdir $workdir
    end

    # Cache dir (rw)
    if test -e $HOME/.cache
        set -a bwrap_args --bind $HOME/.cache $HOME/.cache
    end

    # Git state (ro)
    _yolo_bind ro_seen bwrap_args --ro-bind \
        $HOME/.gitconfig $HOME/.git-credentials $HOME/.config/git $HOME/.ssh

    # Tool-specific state (rw)
    switch $tool_name
        case claude
            for p in $HOME/.claude $HOME/.claude.json
                if test -e $p
                    set -a bwrap_args --bind $p $p
                end
            end
        case codex
            for p in $HOME/.codex $HOME/.config/codex
                if test -e $p
                    set -a bwrap_args --bind $p $p
                end
            end
    end

    # Environment setup
    set -a bwrap_args \
        --chdir $workdir \
        --setenv HOME $HOME \
        --setenv PATH (string join ':' $PATH) \
        --setenv PWD $workdir

    for env_name in \
        TERM COLORTERM LANG LC_ALL NO_COLOR \
        HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY \
        http_proxy https_proxy all_proxy no_proxy \
        ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN ANTHROPIC_BASE_URL ANTHROPIC_MODEL \
        OPENAI_API_KEY OPENAI_BASE_URL OPENAI_ORG_ID OPENAI_PROJECT_ID \
        CODEX_HOME CLAUDE_CODE_SIMPLE
        if set -q $env_name
            set -a bwrap_args --setenv $env_name $$env_name
        end
    end

    # Build command with tool-specific flags
    set -l command_args $original_path
    switch $tool_name
        case codex
            if not contains -- --dangerously-bypass-approvals-and-sandbox $argv
                set -a command_args --dangerously-bypass-approvals-and-sandbox
            end
        case claude
            set -l joined_argv (string join ' ' $argv)
            if not string match -q '*--dangerously-skip-permissions*' $joined_argv
                and not string match -q '*--permission-mode*bypassPermissions*' $joined_argv
                set -a command_args --dangerously-skip-permissions
            end
    end
    set -a command_args $argv

    _yolo_print_cmd bwrap $bwrap_args -- $command_args
    bwrap $bwrap_args $command_args
end
