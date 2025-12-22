return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp-signature-help",
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
			-- { "kdheepak/cmp-latex-symbols" },
			-- { "ray-x/cmp-treesitter" },
			-- { "hrsh7th/cmp-nvim-lua" },

			"onsails/lspkind.nvim", -- for setting cmp format
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
					{ name = 'nvim_lsp_signature_help' },

					-- { name = 'copilot' },
					-- { name = 'codeium' },

					{ name = 'nvim_lsp' },
					{ name = 'path' },
				}, {
					{ name = 'buffer' },
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "text",
						-- mode = "symbol",
						max_width = 50,
						symbol_map = {
							Copilot = "",
							-- Codeium = "",
						}
					})
				}
			})
			-- cmp.setup.cmdline({ '/', '?' }, {
			-- 	mapping = cmp.mapping.preset.cmdline(),
			-- 	sources = {
			-- 		{ name = 'buffer' }
			-- 	}
			-- })
			-- cmp.setup.cmdline(':', {
			-- 	mapping = cmp.mapping.preset.cmdline(),
			-- 	sources = cmp.config.sources({
			-- 		{ name = 'path' }
			-- 	}, {
			-- 		{ name = 'cmdline' }
			-- 	}),
			-- 	matching = { disallow_symbol_nonprefix_matching = false }
			-- })
		end,
	},
	-- {
	-- 	"jcdickinson/codeium.nvim",
	-- 	enabled = false,
	-- 	lazy = true,
	-- 	cmd = "Codeium",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 	},
	-- 	config = function()
	-- 		require("codeium").setup {}
	-- 	end
	-- },
}
