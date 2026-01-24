return {
	"nvim-telescope/telescope.nvim",
	version = '*',
	event = "VeryLazy",
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
					-- i = {
					-- 	["<C-k>"] = actions.move_selection_previous, -- move to prev result
					-- 	["<C-j>"] = actions.move_selection_next,     -- move to next result
					-- }
				}
			},
			-- extensions = {
			-- 	["ui-select"] = {
			-- 		require("telescope.themes").get_dropdown {}
			-- 	}
			-- }
		})

		-- Load extensions
		pcall(telescope.load_extension, "fzf")
		-- pcall(telescope.load_extension, "ui-select")

		-- Keymaps
		vim.keymap.set('n', '<leader>fg', function()
			builtin.live_grep({
				-- these args are passed to the `rg` command
				additional_args = {"--hidden", "--ignore"},
			})
		end, { desc = 'Telescope live grep' })
		vim.keymap.set('n', '<leader>fs', function()
			builtin.find_files({
				hidden = true,
				no_ignore = false,
			})
		end, { desc = 'Telescope find files' })
		vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope grep word' })
		vim.keymap.set('n', '<leader>fh', builtin.git_status, { desc = 'Telescope git status' })
		vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
		vim.keymap.set('n', '<leader>fx', builtin.command_history, { desc = 'Telescope command' })
		vim.keymap.set('n', '<leader>ff', builtin.resume, { desc = 'Telescope resume' })

		-- vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Telescope recent files' })
		-- vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Telescope document symbols (buffer)' })
		-- vim.keymap.set('n', '<leader>fS', builtin.lsp_workspace_symbols, { desc = 'Telescope document symbols (workspace)' })
	end
}
