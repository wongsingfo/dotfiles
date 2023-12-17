local vim = vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- https://github.com/folke/lazy.nvim#-plugin-spec
require('lazy').setup({
	-- The colorscheme should be available when starting
	{
		"morhetz/gruvbox",
		-- "jacoborus/tender.vim",
		-- "folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme gruvbox]])
			vim.cmd([[let g:lightline = { 'colorscheme': 'gruvbox' }]])
		end
	},

	-- More keybinding
	"tomtom/tcomment_vim",
	"tpope/vim-surround",

	-- Utility
	"folke/which-key.nvim",
	"tpope/vim-sleuth",
	"ojroques/nvim-osc52",
	"tpope/vim-vinegar",
	{
		'f-person/git-blame.nvim',
		config = function()
			require'gitblame'.setup({
				enabled = false
			})
		end
	},
	{
		'lewis6991/gitsigns.nvim',
		opts = {},
	},
	{
		"sindrets/diffview.nvim",
		opts = {
			-- Requires nvim-web-devicons
			use_icons = false,
		}
	},

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
			require"fidget".setup{}
		end
	},
	{
		'akinsho/bufferline.nvim',
		config = function()
			require"bufferline".setup{}
		end
	},

	-- I don't want to use icons any more because icons has
	-- compatibility issue with different terminal emulators :(
	-- { "nvim-tree/nvim-web-devicons" },

	-- {
	-- 	"stevearc/dressing.nvim",
	-- 	opts = {},
	-- 	-- event = "VeryLazy",
	-- },
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
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
		"nvim-treesitter/nvim-treesitter",
		config = function ()
			require'nvim-treesitter.configs'.setup {
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
		end
	},
	{
		"zbirenbaum/copilot.lua",
		enabled = false,
		opts = {
			-- disable copilot.lua's suggestion and panel modules,
			-- as they can interfere with completions properly
			-- appearing in copilot-cmp
			suggestion = { enabled = false },
			panel = { enabled = false },
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require('lspconfig')

			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			lspconfig.pyright.setup {}
			lspconfig.tsserver.setup {}

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
		end,
		dependencies = {
			{
				"ray-x/lsp_signature.nvim",
				opts = {},
			},
			{
				"williamboman/mason.nvim",
				build = ":MasonUpdate",
				opts = {},
			},
			-- { "williamboman/mason-lspconfig.nvim" },
			{
				"nvimdev/lspsaga.nvim",
				event = "LspAttach",
				opts = {
					outline = {
						layout = 'float',
					},
					lightbulb = {
						sign = false,
						virtual_text = true,
					},
					ui = {
						code_action = '💡'
					},
				},
			},
			{
				"nvimdev/guard.nvim",
				-- Builtin configuration, optional
				dependencies = {
					"nvimdev/guard-collection",
				},
				config = function()
					local ft = require('guard.filetype')
					-- -- Assuming you have guard-collection
					-- ft('lang'):fmt('format-tool-1')
					-- 	:append('format-tool-2')
					-- 	:env(env_table)
					-- 	:lint('lint-tool-1')
					-- 	:extra(extra_args)
					ft('python'):fmt('black')

					-- Call setup() LAST!
					require('guard').setup({
						-- the only options for the setup function
						fmt_on_save = false,
						-- Use lsp if no formatter was defined for this filetype
						lsp_as_default_formatter = true,
					})
				end,
			},
		},
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-path" },
			{
				"zbirenbaum/copilot-cmp",
				enabled = false,
				after = { "zbirenbaum/copilot.lua" },
				config = function ()
					require("copilot_cmp").setup()
				end
			},
			{
				"jcdickinson/codeium.nvim",
				dependencies = {
					"nvim-lua/plenary.nvim",
				},
				config = function()
					require("codeium").setup {}
				end
			},
			-- { "lukas-reineke/cmp-under-comparator" },
			-- { "saadparwaiz1/cmp_luasnip" },
			-- { "andersevenrud/cmp-tmux" },
			-- { "f3fora/cmp-spell" },
			{ "hrsh7th/cmp-buffer" },
			-- { "kdheepak/cmp-latex-symbols" },
			-- { "ray-x/cmp-treesitter" },
			-- { "hrsh7th/cmp-nvim-lua" },
			{
				"onsails/lspkind.nvim",
			}
		},
		config = function ()
			local cmp = require'cmp'
			local lspkind = require'lspkind'
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
