local function setup_lsp()
	local lspconfig = require('lspconfig')

	-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	-- lspconfig.pyright.setup {}
	-- lspconfig.tsserver.setup {}
	lspconfig.pylsp.setup {}

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	---@diagnostic disable-next-line: inject-field
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
			---@diagnostic disable-next-line: undefined-field
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

	-- lspconfig.bashls.setup {}()
end

local function setup_keybinding()
	local keymap = vim.keymap.set
	keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
	keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
	keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
	keymap("n", "<leader>gk", "<cmd>lua vim.lsp.buf.hover()<CR>")
	keymap("n", "<leader>gr", "<cmd>lua vim.lsp.buf.rename()<CR>")
	keymap("n", "<leader>gd", "<cmd>lua vim.lsp.buf.implementation()<CR>")
	keymap("n", "<leader>gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
	keymap("n", "<leader>gT", "<cmd>lua vim.lsp.buf.typehierarchy()<CR>")
	keymap("n", "<leader>gx", "<cmd>lua vim.lsp.buf.code_action()<CR>")
	keymap("n", "<leader>gi", "<cmd>lua vim.lsp.buf.incoming_calls()<CR>")
	keymap("n", "<leader>go", "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>")
	keymap({ "n", "t" }, "<leader>gf", "<cmd>lua vim.lsp.buf.format()<CR>")
	keymap("n", "<leader>gh", "<cmd>ClangdSwitchSourceHeader<CR>")
end

return {
	{
		"neovim/nvim-lspconfig",
		cmd = "LspStart",
		config = function()
			setup_lsp()
			setup_keybinding()
		end,

		dependencies = {
			"williamboman/mason.nvim",
		},
	},
	{
		"williamboman/mason.nvim",
		lazy = true,
		cmd = "Mason",
		build = ":MasonUpdate",
		config = true,
	},
	{
		"j-hui/fidget.nvim",
		config = true,
	}
}
