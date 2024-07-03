local function setup_textobjects()
	require 'nvim-treesitter.configs'.setup {
		-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
		textobjects = {
			-- lsp_interop = {
			-- 	enable = true,
			-- 	-- border = 'none',
			-- 	floating_preview_opts = {},
			-- 	peek_definition_code = {
			-- 		["<leader>gp"] = "@function.outer",
			-- 	},
			-- },
			swap = {
				enable = true,
				swap_next = {
					["<leader>gs"] = "@parameter.inner",
				},
				swap_previous = {
					["<leader>gS"] = "@parameter.inner", },
			},
			select = {
				enable = true,

				-- Automatically jump forward to textobj, similar to targets.vim
				lookahead = true,

				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["am"] = "@function.outer",
					["im"] = "@function.inner",
					["ab"] = "@block.outer",
					["ib"] = "@block.inner",
					["a,"] = "@parameter.outer",
					["i,"] = "@parameter.inner",
					-- ["ac"] = "@class.outer",
					-- You can optionally set descriptions to the mappings (used in the desc parameter of
					-- nvim_buf_set_keymap) which plugins like which-key display
					-- ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
					-- You can also use captures from other query groups like `locals.scm`
					-- ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
				},
				-- You can choose the select mode (default is charwise 'v')
				--
				-- Can also be a function which gets passed a table with the keys
				-- * query_string: eg '@function.inner'
				-- * method: eg 'v' or 'o'
				-- and should return the mode ('v', 'V', or '<c-v>') or a table
				-- mapping query_strings to modes.
				-- selection_modes = {
				-- 	['@parameter.outer'] = 'v', -- charwise
				-- 	['@function.outer'] = 'V', -- linewise
				-- 	['@class.outer'] = '<c-v>', -- blockwise
				-- },

				-- If you set this to `true` (default is `false`) then any textobject is
				-- extended to include preceding or succeeding whitespace. Succeeding
				-- whitespace has priority in order to act similarly to eg the built-in
				-- `ap`.
				--
				-- Can also be a function which gets passed a table with the keys
				-- * query_string: eg '@function.inner'
				-- * selection_mode: eg 'v'
				-- and should return true or false
				include_surrounding_whitespace = true,
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					["]m"] = "@function.outer",
					-- ["]]"] = { query = "@class.outer", desc = "Next class start" },
					-- --
					-- -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
					-- ["]o"] = "@loop.*",
					-- -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
					-- --
					-- -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
					-- -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
					-- ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
					-- ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					-- ["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					-- ["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					-- ["[]"] = "@class.outer",
				},
				-- Below will go to either the start or the end, whichever is closer.
				-- Use if you want more granular movements
				-- Make it even more gradual by adding multiple queries and regex.
				-- goto_next = {
				-- 	["]d"] = "@conditional.outer",
				-- },
				-- goto_previous = {
				-- 	["[d"] = "@conditional.outer",
				-- }
			},
		},
	}
end

local function setup_keybinding()
	local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
	-- Repeat movement with ; and ,
	-- ensure ; goes forward and , goes backward regardless of the last direction
	vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
	vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
	-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
	vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
	vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
	vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
	vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
end

return {
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },

		config = function()
			setup_textobjects()
			setup_keybinding()
		end
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require 'treesitter-context'.setup {
				mode = 'cursor',
				separator = '┄',
			}
		end
	},
	{
		"nvim-treesitter/playground", -- For debugging nvim-treesitter
		lazy = true,
		cmd = { "Inspect", "InspectTree" },
		config = function()
			require 'nvim-treesitter.configs'.setup {
				query_linter = {
					enable = true,
					use_virtual_text = true,
					lint_events = { "BufWrite", "CursorHold" },
				},
			}
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",

		-- Reduce the priority level of Treesitter to ensure that changes made to
		-- `nvim_set_hl` are after Treesitter is loaded.
		-- (the default priority is 50)
		priority = 30,
		config = function()
			require 'nvim-treesitter.configs'.setup {
				ensure_installed = {
					"bash",
					"c",
					"cpp",
					"lua",
					"markdown",
					"markdown_inline",
					"python",
					"rust",
					"vimdoc",
				},
				-- Indentation based on treesitter for the = operator. NOTE: This is an experimental feature.
				indent = { enable = true },
				matchup = { enable = true, },
				highlight = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "vv", -- set to `false` to disable one of the mappings
						node_incremental = "v",
						scope_incremental = false,
						node_decremental = "u",
					},
				},
			}
			-- Fix bug: https://www.reddit.com/r/vim/comments/s8md17/how_to_fix_the_cursor_line_getting_cut_off_like/
			-- API references:
			-- - https://neovim.io/doc/user/api.html#nvim_set_hl()
			-- - https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#available-modules
			-- print(vim.inspect(x))
			-- Or use `:Inspect` in treesitter-playground
			local val = vim.api.nvim_get_hl(0, { name = "Normal" })
			val.bg = nil
			---@diagnostic disable-next-line: inject-field
			val.ctermbg = nil
			---@diagnostic disable-next-line: param-type-mismatch
			vim.api.nvim_set_hl(0, "@operator", val)
		end
	},

}
