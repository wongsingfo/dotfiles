function osc52 --description "Copy stdin to the clipboard via OSC 52"
	if not command -q base64
		echo "osc52: base64 command not found" >&2
		return 127
	end

	printf '\e]52;c;'
	# Keep base64 directly connected to the function's stdin. Command
	# substitutions do not inherit a function's pipeline input in Fish.
	command base64 | while read -l line
		printf '%s' "$line"
	end
	printf '\a'
end
