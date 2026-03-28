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
    set -l xdg_config_home (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo $HOME/.config)
    set -l xdg_cache_home (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)

    set -l bwrap_args \
        --clearenv \
        --proc /proc \
        --dev /dev \
        --tmpfs /tmp \
        --unshare-all \
        --share-net \
        --die-with-parent

    set -l ro_seen
    set -l rw_seen
    set -l dir_seen

    # System mounts (ro)
    for p in /usr /bin /lib /lib64 /etc
        if test -e $p; and not contains -- $p $ro_seen
            set -a ro_seen $p
            set -a bwrap_args --ro-bind $p $p
        end
    end

    # DNS resolver runtime mounts
    if test -e /etc/resolv.conf
        set -l resolv_source (readlink -f -- /etc/resolv.conf)
        if test -n "$resolv_source"; and string match -q '/run/*' $resolv_source
            set -l runtime_dir (dirname -- $resolv_source)
            set -l current /run
            if not contains -- $current $dir_seen
                set -a dir_seen $current
                set -a bwrap_args --dir $current
            end
            set -l relative (string replace '/run/' '' $runtime_dir)
            for component in (string split '/' $relative)
                set current $current/$component
                if not contains -- $current $dir_seen
                    set -a dir_seen $current
                    set -a bwrap_args --dir $current
                end
            end
            if test -e $runtime_dir; and not contains -- $runtime_dir $ro_seen
                set -a ro_seen $runtime_dir
                set -a bwrap_args --ro-bind $runtime_dir $runtime_dir
            end
        end
    end

    # Mount command paths (ro)
    for candidate in $original_path $real_path
        set -l matched_prefix false
        for prefix in $HOME/.npm $HOME/.cargo $HOME/.local
            if test -e $prefix; and string match -q "$prefix/*" $candidate
                if not contains -- $prefix $ro_seen
                    set -a ro_seen $prefix
                    set -a bwrap_args --ro-bind $prefix $prefix
                end
                set matched_prefix true
                break
            end
        end
        if test $matched_prefix = true
            continue
        end
        set -l is_system false
        for sys_prefix in /usr /bin /lib /lib64 /etc
            if test $candidate = $sys_prefix; or string match -q "$sys_prefix/*" $candidate
                set is_system true
                break
            end
        end
        if test $is_system = false
            if not string match -q "$workdir" $candidate; and not string match -q "$workdir/*" $candidate
                set -l parent (dirname -- $candidate)
                if test -e $parent; and not contains -- $parent $ro_seen
                    set -a ro_seen $parent
                    set -a bwrap_args --ro-bind $parent $parent
                end
            end
        end
    end

    # Working directory (rw)
    if test -e $workdir; and not contains -- $workdir $rw_seen
        set -a rw_seen $workdir
        set -a bwrap_args --bind $workdir $workdir
    end

    # Cache dir (rw)
    if test -e $xdg_cache_home; and not contains -- $xdg_cache_home $rw_seen
        set -a rw_seen $xdg_cache_home
        set -a bwrap_args --bind $xdg_cache_home $xdg_cache_home
    end

    # Git state (ro)
    for p in $HOME/.gitconfig $HOME/.git-credentials $xdg_config_home/git $HOME/.ssh
        if test -e $p; and not contains -- $p $ro_seen
            set -a ro_seen $p
            set -a bwrap_args --ro-bind $p $p
        end
    end

    # Tool-specific state (rw)
    switch $tool_name
        case claude
            for p in $HOME/.claude $HOME/.claude.json
                if test -e $p; and not contains -- $p $rw_seen
                    set -a rw_seen $p
                    set -a bwrap_args --bind $p $p
                end
            end
        case codex
            for p in $HOME/.codex $xdg_config_home/codex
                if test -e $p; and not contains -- $p $rw_seen
                    set -a rw_seen $p
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
        XDG_CONFIG_HOME XDG_CACHE_HOME \
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
            set -l has_skip false
            if contains -- --dangerously-skip-permissions $argv
                set has_skip true
            end
            if test $has_skip = false
                for i in (seq (count $argv))
                    if test "$argv[$i]" = --permission-mode
                        set -l next (math $i + 1)
                        if test $next -le (count $argv); and test "$argv[$next]" = bypassPermissions
                            set has_skip true
                            break
                        end
                    else if test "$argv[$i]" = --permission-mode=bypassPermissions
                        set has_skip true
                        break
                    end
                end
            end
            if test $has_skip = false
                set -a command_args --dangerously-skip-permissions
            end
    end
    set -a command_args $argv

    echo "+" bwrap $bwrap_args $command_args >&2
    bwrap $bwrap_args $command_args
end
