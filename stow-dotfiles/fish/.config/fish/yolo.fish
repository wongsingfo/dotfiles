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

function _yolo_build_env_args --description "Emit env(1) args from parser state" --no-scope-shadowing
    # `env` requires all -u flags before any NAME=VALUE assignments.
    set -l unsets
    set -l sets
    set -l count (count $loaded_env_names)
    if test $count -gt 0
        for i in (seq $count)
            set -l name $loaded_env_names[$i]
            set -l value $loaded_env_values[$i]
            if test -z "$value"
                set -a unsets -u $name
            else
                set -a sets "$name=$value"
            end
        end
    end
    for arg in $unsets $sets
        echo $arg
    end
end

function _yolo_usage --description "Print yolo usage"
    set -l env_file $argv[1]

    echo "usage: yolo [options] <command> [args...]" >&2
    if not contains -- --verbose $argv
        return
    end

    echo >&2
    echo "Run a command with environment overrides from flags or .env.toml." >&2
    echo >&2
    echo "Options:" >&2
    echo "  --help, -h          Show this help message" >&2
    echo "  --list              List all available env groups in .env.toml" >&2
    echo "  --setenv NAME       Preserve NAME from the parent environment" >&2
    echo "  --setenv NAME=VAL   Set NAME to VAL for the command" >&2
    echo "  --setenv NAME=      Unset NAME for the command" >&2
    echo "                      (can be specified multiple times)" >&2
    echo "  --loadenv GROUP     Load env variables from .env.toml under [GROUP]" >&2
    echo "                      (empty env values unset variables; argv=[...] adds args)" >&2
    echo "                      (can be specified multiple times)" >&2
    echo >&2
    echo "Environment file: $env_file" >&2
    echo >&2
    echo "Examples:" >&2
    echo "  yolo claude" >&2
    echo "  yolo --setenv MY_TOKEN --setenv DEBUG claude --print" >&2
    echo "  yolo --loadenv openai claude" >&2
    echo "  yolo --loadenv codex codex" >&2
end

function _yolo_add_setenv_arg --description "Apply one --setenv argument to parser state" --no-scope-shadowing
    set -l setenv_arg $argv[1]
    set -l name $setenv_arg
    set -l value
    if string match -q '*=*' -- $setenv_arg
        set name (string replace -r '=.*' '' -- $setenv_arg)
        set value (string replace -r '^[^=]*=' '' -- $setenv_arg)
    else if set -q $name
        set value $$name
    end
    set -a loaded_env_names $name
    set -a loaded_env_values "$value"
end

function _yolo_add_loadenv_group --description "Load one env group into parser state" --no-scope-shadowing
    set -l env_file $argv[1]
    set -l group $argv[2]
    set -l pairs (_yolo_load_env_group "$env_file" "$group")
    if test $status -ne 0
        return 1
    end
    if test (count $pairs) -eq 0
        echo "yolo: no env variables or argv found in group [$group]" >&2
        return 1
    end
    for pair in $pairs
        if string match -rq '^__YOLO_ARGV__=(.*)$' -- "$pair"
            set -l m (string match -r '^__YOLO_ARGV__=(.*)$' -- "$pair")
            set -a loaded_argv "$m[2]"
        else if string match -rq '^([^=]+)=(.*)$' -- "$pair"
            set -l m (string match -r '^([^=]+)=(.*)$' -- "$pair")
            set -a loaded_env_names $m[2]
            set -a loaded_env_values "$m[3]"
        end
    end
end

function _yolo_list_env_groups --description "List all env groups from .env.toml"
    # argv[1] = toml file path
    set -l toml_file $argv[1]
    if not test -f "$toml_file"
        echo "yolo: env file not found: $toml_file" >&2
        return 1
    end
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
            echo "$section"
        end
    end <"$toml_file"
end

function _yolo_split_toml_array_items --description "Split TOML array items without splitting inside quoted strings"
    set -l raw $argv[1]
    set -l current
    set -l quote
    set -l escaped false
    set -l len (string length -- "$raw")

    if test $len -eq 0
        return 0
    end

    for i in (seq $len)
        set -l ch (string sub -s $i -l 1 -- "$raw")

        if test "$escaped" = true
            set current "$current$ch"
            set escaped false
            continue
        end

        if test "$quote" = '"'; and test "$ch" = "\\"
            set current "$current$ch"
            set escaped true
            continue
        end

        if test -n "$quote"
            if test "$ch" = "$quote"
                set quote
            end
            set current "$current$ch"
            continue
        end

        if test "$ch" = '"'; or test "$ch" = "'"
            set quote "$ch"
            set current "$current$ch"
        else if test "$ch" = ,
            echo "$current"
            set current
        else
            set current "$current$ch"
        end
    end

    echo "$current"
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
            if string match -rq '^argv\s*=\s*\[(.*)$' "$line"
                set -l m (string match -r '^argv\s*=\s*\[(.*)$' "$line")
                set -l buf $m[2]
                # If the closing ] is not on this line, keep reading
                # subsequent lines until we find it. This supports the
                # multi-line TOML array form:
                #   argv = [
                #       "--flag",
                #       "value",
                #   ]
                if not string match -rq '\]\s*$' "$buf"
                    while read -l cont
                        set cont (string trim -- "$cont")
                        # Skip blank lines and whole-line comments between items
                        if test -z "$cont"; or string match -q '#*' "$cont"
                            continue
                        end
                        if string match -rq '^(.*)\]\s*$' "$cont"
                            set -l cm (string match -r '^(.*)\]\s*$' "$cont")
                            if test -n "$cm[2]"
                                set buf "$buf,$cm[2]"
                            end
                            break
                        else
                            set buf "$buf,$cont"
                        end
                    end
                else
                    set buf (string replace -r '\]\s*$' '' -- "$buf")
                end
                set -l argv_items (_yolo_split_toml_array_items "$buf")
                for item in $argv_items
                    set item (string trim -- "$item")
                    if test -z "$item"
                        continue
                    end
                    if string match -rq '^"(.*)"$' "$item"
                        set -l value (string match -r '^"(.*)"$' "$item")[2]
                        echo "__YOLO_ARGV__=$value"
                    else if string match -rq "^'(.*)'\$" "$item"
                        set -l value (string match -r "^'(.*)'\$" "$item")[2]
                        echo "__YOLO_ARGV__=$value"
                    else
                        echo "yolo: argv entries must be quoted strings: $item" >&2
                        return 1
                    end
                end
            else if string match -rq '^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"(.*)"$' "$line"
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

function yolo --description "Run a command with environment overrides"
    set -l loaded_env_names
    set -l loaded_env_values
    set -l loaded_argv
    set -l positional
    set -l i 1
    set -l env_file (dirname (status filename))/.env.toml
    while test $i -le (count $argv)
        switch $argv[$i]
            case --help -h
                _yolo_usage "$env_file" --verbose
                return 0
            case --list
                set -l groups (_yolo_list_env_groups "$env_file")
                if test $status -eq 0
                    echo "Available env groups in $env_file:" >&2
                    echo >&2
                    for group in $groups
                        echo "  - $group" >&2
                    end
                end
                return 0
            case --setenv
                set i (math $i + 1)
                if test $i -gt (count $argv)
                    echo "yolo: --setenv requires an argument" >&2
                    return 1
                end
                _yolo_add_setenv_arg $argv[$i]
            case --loadenv
                set i (math $i + 1)
                if test $i -gt (count $argv)
                    echo "yolo: --loadenv requires a group name" >&2
                    return 1
                end
                _yolo_add_loadenv_group "$env_file" $argv[$i]
                or return 1
            case '*'
                # First non-flag argument starts the command; collect the rest as-is
                set positional $argv[$i..-1]
                break
        end
        set i (math $i + 1)
    end

    if test (count $positional) -eq 0
        _yolo_usage "$env_file"
        return 1
    end

    set -l original_command $positional[1]
    set -l command_argv $positional[2..-1]

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

    set -l command_args $original_path
    set -a command_args $loaded_argv
    set -a command_args $command_argv

    set -l env_args (_yolo_build_env_args)
    if test (count $env_args) -gt 0
        _yolo_print_cmd env $env_args -- $command_args
        env $env_args $command_args
    else
        _yolo_print_cmd $command_args
        $command_args
    end
end
