local keymap = vim.keymap.set

local function get_file_line_info()
	local file_path = vim.fn.expand('%')
	local line_number = vim.fn.line('.')
	local line_content = vim.fn.getline('.')
	local result = string.format("%s:%d:\n%s", file_path, line_number, line_content)
	return result
end

return {
	"ojroques/nvim-osc52",
	config = function()
		local osc52 = require('osc52')
		keymap('n', '<leader>c', osc52.copy_operator, { expr = true })
		keymap('n', '<leader>cc', '<leader>c_', { remap = true })
		keymap('v', '<leader>c', osc52.copy_visual)
		keymap('n', '<leader>cg', function()
			osc52.copy(get_file_line_info())
		end)
	end
}
