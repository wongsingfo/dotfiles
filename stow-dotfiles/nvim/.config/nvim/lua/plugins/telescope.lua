local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
	defaults = {
		mappings = {},
	},
})

-- Load extensions
pcall(telescope.load_extension, "fzf")
-- pcall(telescope.load_extension, "ui-select")

-- Keymaps
vim.keymap.set("n", "<leader>fg", function()
	builtin.live_grep({
		additional_args = { "--hidden", "--ignore" },
	})
end, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fs", function()
	builtin.find_files({
		hidden = true,
		no_ignore = false,
	})
end, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Telescope grep word" })
vim.keymap.set("n", "<leader>fh", builtin.git_status, { desc = "Telescope git status" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fx", builtin.command_history, { desc = "Telescope command" })
vim.keymap.set("n", "<leader>ff", builtin.resume, { desc = "Telescope resume" })
