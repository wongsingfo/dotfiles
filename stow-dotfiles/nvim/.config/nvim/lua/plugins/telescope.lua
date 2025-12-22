return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-telescope/telescope-ui-select.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next,     -- move to next result
					}
				}
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown {}
				}
			}
		})

		-- Load extensions
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")

		-- Keymaps
		vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
		vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
		vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
		vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Telescope recent files' })
		vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope grep word' })
		vim.keymap.set('n', '<leader>fs', builtin.git_status, { desc = 'Telescope git status' })
		vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Telescope resume' })
	end
}
