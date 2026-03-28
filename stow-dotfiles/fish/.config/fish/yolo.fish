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

    # Working directory (rw)
    if test -e $workdir
        set -a bwrap_args --bind $workdir $workdir
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
    set -l profile "(version 1)
(deny default)
(allow network*)
(allow process-exec)
(allow process-fork)
(allow sysctl-read)
(allow mach*)
(allow ipc-posix-shm*)
(allow signal)
(allow file-read-metadata)

; System (ro)
(allow file-read* (subpath \"/usr\"))
(allow file-read* (subpath \"/bin\"))
(allow file-read* (subpath \"/sbin\"))
(allow file-read* (subpath \"/etc\"))
(allow file-read* (subpath \"/Library\"))
(allow file-read* (subpath \"/System\"))
(allow file-read* (subpath \"/private\"))
(allow file-read* (subpath \"/dev\"))
(allow file-read* (subpath \"/tmp\"))
(allow file-read* file-write* (subpath \"/tmp\"))

; Working directory (rw)
(allow file-read* file-write* (subpath \"$workdir\"))

; Cache (rw)
(allow file-read* file-write* (subpath \"$HOME/.cache\"))"

    # Git/SSH state (ro)
    for p in $HOME/.gitconfig $HOME/.git-credentials $HOME/.config/git $HOME/.ssh
        if test -e $p
            if test -d $p
                set profile "$profile
(allow file-read* (subpath \"$p\"))"
            else
                set profile "$profile
(allow file-read* (literal \"$p\"))"
            end
        end
    end

    # Command ro paths
    for p in $ro_paths
        if test -e $p
            if test -d $p
                set profile "$profile
(allow file-read* (subpath \"$p\"))"
            else
                set -l parent (dirname -- $p)
                set profile "$profile
(allow file-read* (subpath \"$parent\"))"
            end
        end
    end

    # Extra rw paths (tool state)
    for p in $rw_paths
        if test -e $p
            if test -d $p
                set profile "$profile
(allow file-read* file-write* (subpath \"$p\"))"
            else
                set profile "$profile
(allow file-read* file-write* (literal \"$p\"))"
            end
        end
    end

    echo "+ sandbox-exec -p '...' $command_args" >&2
    sandbox-exec -p $profile $command_args
end

function yolo --description "Run a command in a sandbox"
    if test (count $argv) -eq 0
        echo "usage: yolo <command> [args...]" >&2
        return 1
    end

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
            for p in $HOME/.codex $HOME/.config/codex
                if test -e $p
                    set -a rw_paths $p
                end
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

    # Dispatch to OS-specific backend
    set -l os (uname -s)
    switch $os
        case Linux
            if not command -q bwrap
                echo "bwrap is not installed or not on PATH" >&2
                return 1
            end
            _yolo_bwrap $ro_paths -- $rw_paths -- $command_args
        case Darwin
            if not command -q sandbox-exec
                echo "sandbox-exec is not available" >&2
                return 1
            end
            _yolo_sandbox_exec $ro_paths -- $rw_paths -- $command_args
        case '*'
            echo "unsupported OS: $os" >&2
            return 1
    end
end
