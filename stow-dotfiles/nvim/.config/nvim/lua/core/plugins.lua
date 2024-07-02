local vim = vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local use_ghproxy = false
local lazy_url = "https://github.com/folke/lazy.nvim.git"
local lazy_url_format = "https://github.com/%s.git"

if use_ghproxy then
	local ghproxy_url = "https://ghproxy.org/"
	lazy_url = ghproxy_url .. lazy_url
	lazy_url_format = ghproxy_url .. lazy_url_format
end

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		lazy_url,
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- https://github.com/folke/lazy.nvim#-plugin-spec
require('lazy').setup({
	git = {
		url_format = lazy_url_format,
	},
	-- The colorscheme should be available when starting
	{
		"morhetz/gruvbox",
		-- "jacoborus/tender.vim",
		-- "folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- https://github.com/morhetz/gruvbox/wiki/Configuration#ggruvbox_sign_column
			vim.cmd([[let g:gruvbox_sign_column = 'bg0']])
			vim.cmd.colorscheme('gruvbox')
		end
	},

	-- More keybinding
	"tomtom/tcomment_vim",
	"tpope/vim-surround",
	{
		-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
		"nvim-treesitter/nvim-treesitter-textobjects",
		config = function()
			require 'nvim-treesitter.configs'.setup {
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
							["af"] = "@function.outer",
							["if"] = "@function.inner",
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
							["]f"] = "@function.outer",
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
							["]F"] = "@function.outer",
							-- ["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							-- ["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
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
	},

	-- Utility
	"folke/which-key.nvim",
	"tpope/vim-sleuth", -- auto set buffer options (etc. indent)
	"ojroques/nvim-osc52",
	{
		'nmac427/guess-indent.nvim',
		config = function() require('guess-indent').setup {} end,
	},
	-- "tpope/vim-vinegar", -- netrw
	-- Version Control (git)
	-- {
	-- 	'f-person/git-blame.nvim',
	-- 	config = function()
	-- 		require'gitblame'.setup({
	-- 			enabled = false
	-- 		})
	-- 	end
	-- },
	-- "airblade/vim-gitgutter",
	{
		'lewis6991/gitsigns.nvim',
		opts = {}
	},
	-- {
	-- 	"sindrets/diffview.nvim",
	-- 	opts = {
	-- 		-- Requires nvim-web-devicons
	-- 		use_icons = false,
	-- 	}
	-- },

	-- UI
	-- {
	-- 	"nvim-lualine/lualine.nvim",
	-- 	opts = {},
	-- },
	{
		-- Show LSP status
		'j-hui/fidget.nvim',
		tag = "legacy",
		event = "LspAttach",
		config = function()
			require "fidget".setup {}
		end
	},
	-- {
	-- 	'akinsho/bufferline.nvim',
	-- 	config = function()
	-- 		require"bufferline".setup{}
	-- 	end
	-- },
	"itchyny/lightline.vim", -- statusline

	-- I don't want to use icons any more because icons has
	-- compatibility issue with different terminal emulators :(
	-- { "nvim-tree/nvim-web-devicons" },

	-- {
	-- 	"stevearc/dressing.nvim",
	-- 	"neovim/nvim-lspconfig",
	--  	opts = {},
	-- 	-- event = "VeryLazy",
	-- },
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		-- Ref: https://yeripratama.com/blog/customizing-nvim-telescope/
		opts = {
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						-- Fullscreen
						prompt_position = "top",
						width = { padding = 0 },
						height = { padding = 0 },
						preview_width = 0.5,
					},
				},
				sorting_strategy = "ascending",
			},
		},
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
			"nvim-lua/plenary.nvim",
			build = "make",
			config = function()
				require("telescope").load_extension("fzf")
			end,
		},
	},
	{
		"chentoast/marks.nvim",
		opts = {},
	},
	{ "kevinhwang91/rnvimr" },
	-- {
	-- 	"lukas-reineke/indent-blankline.nvim",
	-- 	config = function()
	-- 		-- https://github.com/lukas-reineke/indent-blankline.nvim/issues/819
	-- 		-- vim.opt.list = true
	-- 		-- vim.opt.listchars = {
	-- 		-- 	trail = '•',
	-- 		-- 	lead = '.',
	-- 		-- 	tab = '|.',
	-- 		-- 	extends = '»',
	-- 		-- 	precedes = '«',
	-- 		-- 	nbsp = '␣',
	-- 		-- }
	-- 		require("ibl").setup {
	-- 			scope = {
	-- 				-- show_end = false, -- Not good for python
	-- 			}
	-- 		}
	-- 	end
	-- },

	-- Completion
	{
		"nvim-treesitter/nvim-treesitter-context",
		enabled = true,
		opts = { mode = "cursor" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		}
	},
	{
		"nvim-treesitter/playground", -- For debugging nvim-treesitter
		enabled = false,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		-- Lower the priority of treesitter to ensure the modification
		-- to nvim_set_hl is the last (the default priority is 50)
		priority = 30,
		config = function()
			require 'nvim-treesitter.configs'.setup {
				ensure_installed = {
					"c",
					"cpp",
					"lua",
					"bash",
					"rust",
					"python",
					"markdown",
					"markdown_inline",
				},
				indent = { enable = true },
				matchup = {
					enable = true,
				},
				highlight = { enable = true },
				query_linter = {
					enable = true,
					use_virtual_text = true,
					lint_events = { "BufWrite", "CursorHold" },
				},
			}

			-- Fix bug: https://www.reddit.com/r/vim/comments/s8md17/how_to_fix_the_cursor_line_getting_cut_off_like/
			-- API references:
			-- - https://neovim.io/doc/user/api.html#nvim_set_hl()
			-- - https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#available-modules
			-- print(vim.inspect(x))
			local val = vim.api.nvim_get_hl(0, { name = "Normal" })
			val.bg = nil
			val.ctermbg = nil
			vim.api.nvim_set_hl(0, "@operator", val)
		end
	},
	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	enabled = false,
	-- 	opts = {
	-- 		-- disable copilot.lua's suggestion and panel modules,
	-- 		-- as they can interfere with completions properly
	-- 		-- appearing in copilot-cmp
	-- 		suggestion = { enabled = false },
	-- 		panel = { enabled = false },
	-- 	},
	-- },
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require('lspconfig')

			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			-- lspconfig.pyright.setup {}
			-- lspconfig.tsserver.setup {}
			lspconfig.pylsp.setup {}

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.offsetEncoding = 'utf-8'
			lspconfig.clangd.setup {
				capabilities = capabilities
			}

			lspconfig.rust_analyzer.setup {
				-- Server-specific settings. See `:help lspconfig-setup`
				settings = {
					['rust-analyzer'] = {},
				},
			}

			lspconfig.lua_ls.setup {
				-- If you primarily use lua-language-server for Neovim, and want to provide completions, analysis,
				-- and location handling for plugins on runtime path, you can use the following settings.
				on_init = function(client)
					local path = client.workspace_folders[1].name
					if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
						return
					end

					client.config.settings.Lua = vim.tbl_deep_extend('force',
						client.config.settings.Lua, {
							runtime = {
								-- Tell the language server which version of Lua you're using
								-- (most likely LuaJIT in the case of Neovim)
								version = 'LuaJIT'
							},
							-- Make the server aware of Neovim runtime files
							workspace = {
								checkThirdParty = false,
								library = {
									vim.env.VIMRUNTIME
									-- Depending on the usage, you might want to add additional paths here.
									-- "${3rd}/luv/library"
									-- "${3rd}/busted/library",
								}
								-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
								-- library = vim.api.nvim_get_runtime_file("", true)
							}
						})
				end,
				settings = {
					Lua = {}
				}
			}
		end,
		dependencies = {
			{
				"ray-x/lsp_signature.nvim",
				opts = {},
			},
			{
				"williamboman/mason.nvim",
				cmd = "Mason",
				build = ":MasonUpdate",
				opts = {},
			},
			-- { "williamboman/mason-lspconfig.nvim" },
			-- {
			-- 	"nvimdev/lspsaga.nvim",
			-- 	event = "LspAttach",
			-- 	opts = {
			-- 		-- https://github.com/nvimdev/lspsaga.nvim/blob/main/lua/lspsaga/init.lua
			-- 		outline = {
			-- 			layout = 'float',
			-- 		},
			-- 		lightbulb = {
			-- 			enable = false,
			-- 			sign = false,
			-- 			virtual_text = true,
			-- 		},
			-- 		symbol_in_winbar = {
			-- 			enable = false,
			-- 		},
			-- 		ui = {
			-- 			code_action = '💡'
			-- 		},
			-- 	},
			-- },
		},
	},
	-- {
	-- 	"nvimdev/guard.nvim",
	-- 	enabled = false,
	-- 	-- Builtin configuration, optional
	-- 	dependencies = {
	-- 		"nvimdev/guard-collection",
	-- 		"neovim/nvim-lspconfig",
	-- 	},
	-- 	config = function()
	-- 		local ft = require('guard.filetype')
	-- 		-- -- Assuming you have guard-collection
	-- 		-- ft('lang'):fmt('format-tool-1')
	-- 		-- 	:append('format-tool-2')
	-- 		-- 	:env(env_table)
	-- 		-- 	:lint('lint-tool-1')
	-- 		-- 	:extra(extra_args)
	-- 		ft('python'):fmt('black')
	--
	-- 		-- Call setup() LAST!
	-- 		require('guard').setup({
	-- 			fmt_on_save = false,
	-- 			-- Use lsp if no formatter was defined for this filetype
	-- 			lsp_as_default_formatter = true,
	-- 		})
	-- 	end,
	-- },
	{
		-- make Neovim's quickfix window better
		'kevinhwang91/nvim-bqf',
	},
	{
		"jcdickinson/codeium.nvim",
		cmd = "Codeium",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("codeium").setup {}
		end
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-path" },
			-- {
			-- 	"zbirenbaum/copilot-cmp",
			-- 	enabled = false,
			-- 	after = { "zbirenbaum/copilot.lua" },
			-- 	config = function ()
			-- 		require("copilot_cmp").setup()
			-- 	end
			-- },
			-- { "lukas-reineke/cmp-under-comparator" },
			-- { "saadparwaiz1/cmp_luasnip" },
			-- { "andersevenrud/cmp-tmux" },
			-- { "f3fora/cmp-spell" },
			{ "hrsh7th/cmp-buffer" },
			-- { "kdheepak/cmp-latex-symbols" },
			-- { "ray-x/cmp-treesitter" },
			-- { "hrsh7th/cmp-nvim-lua" },
			{ "onsails/lspkind.nvim", }
		},
		config = function()
			local cmp = require 'cmp'
			local lspkind = require 'lspkind'
			cmp.setup({
				window = {
					-- completion = cmp.config.window.bordered(),
					-- documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
				}),
				sources = cmp.config.sources({
					{ name = 'copilot' },
					{ name = 'codeium' },
					{ name = 'nvim_lsp' },
					{ name = 'path' },
					-- { name = 'vsnip' }, -- For vsnip users.
					-- { name = 'luasnip' }, -- For luasnip users.
					-- { name = 'ultisnips' }, -- For ultisnips users.
					-- { name = 'snippy' }, -- For snippy users.
				}, {
					{ name = 'buffer' },
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "text",
						max_width = 50,
						symbol_map = {
							Copilot = "",
							Codeium = "",
						}
					})
				}
			})
		end,
	},
})
