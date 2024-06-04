local vim = vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local use_ghproxy = false
local lazy_url = "https://github.com/folke/lazy.nvim.git"
local lazy_url_format = "https://github.com/%s.git"

if use_ghproxy then
	local ghproxy_url = "https://ghproxy.org/"
	lazy_url = ghproxy_url.. lazy_url
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

	-- Utility
	"folke/which-key.nvim",
	"tpope/vim-sleuth",
	"ojroques/nvim-osc52",
	"tpope/vim-vinegar",
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
			require"fidget".setup{}
		end
	},
	-- {
	-- 	'akinsho/bufferline.nvim',
	-- 	config = function()
	-- 		require"bufferline".setup{}
	-- 	end
	-- },
	"itchyny/lightline.vim",

	-- I don't want to use icons any more because icons has
	-- compatibility issue with different terminal emulators :(
	-- { "nvim-tree/nvim-web-devicons" },

	-- {
	-- 	"stevearc/dressing.nvim",
		"neovim/nvim-lspconfig",
	-- 	opts = {},
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
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			-- https://github.com/lukas-reineke/indent-blankline.nvim/issues/819
			vim.opt.list = true
			vim.opt.listchars = {
				trail = '•',
				tab = '| ',
				extends = '»',
				precedes = '«',
				nbsp = '␣',
			}
			require("ibl").setup {
				scope = {
					show_end = false, -- Not good for python
				}
			}
		end
	},

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
		"nvim-treesitter/playground",  -- For debugging nvim-treesitter
		enabled = false,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		-- Lower the priority of treesitter to ensure the modification
		-- to nvim_set_hl is the last (the default priority is 50)
		priority = 30,
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

			-- Fix bug: https://www.reddit.com/r/vim/comments/s8md17/how_to_fix_the_cursor_line_getting_cut_off_like/
			-- API references:
			-- - https://neovim.io/doc/user/api.html#nvim_set_hl()
			-- - https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#available-modules
			-- print(vim.inspect(x))
			local val = vim.api.nvim_get_hl(0, {name = "Normal"})
			val.bg = nil
			val.ctermbg = nil
			vim.api.nvim_set_hl(0, "@operator", val)
		end
	},
	{
		"robitx/gp.nvim",
		config = function()
			local home = os.getenv("HOME")
			local inDockerContainer = os.getenv("USER") == "ubuntu"
			local proxy = inDockerContainer and "http://172.17.0.1:7890" or "http://127.0.0.1:7890"
			require("gp").setup {
				openai_api_key = { "cat", home.."/.config/OPENAI_API_KEY" },
				curl_params = {"--proxy", proxy}
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
		},
	},
	{
		"nvimdev/guard.nvim",
		-- Builtin configuration, optional
		dependencies = {
			"nvimdev/guard-collection",
			"neovim/nvim-lspconfig",
		},
		-- priority = 1000,
		-- cmd = "GuardFmt",
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
	{
		"jcdickinson/codeium.nvim",
		lazy = true,
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
			{
				"zbirenbaum/copilot-cmp",
				enabled = false,
				after = { "zbirenbaum/copilot.lua" },
				config = function ()
					require("copilot_cmp").setup()
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
