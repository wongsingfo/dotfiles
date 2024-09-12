local function setup_clangd(lspconfig)
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	---@diagnostic disable-next-line: inject-field
	capabilities.offsetEncoding = 'utf-8'
	lspconfig.clangd.setup {
		capabilities = capabilities
	}
end

local function setup_rust_analyzer(lspconfig)
	lspconfig.rust_analyzer.setup {
		-- Server-specific settings. See `:help lspconfig-setup`
		settings = {
			['rust-analyzer'] = {},
		},
	}
end

local function setup_lua_ls(lspconfig)
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
end

local function setup_py_lsp(lspconfig)
	lspconfig.pylsp.setup {
		settings = {
			pylsp = {
				plugins = {
					pycodestyle = {
						ignore = { 'W391' },
						maxLineLength = 150
					}
				}
			}
		}
	}
end

local function setup_texlab(lspconfig)
	lspconfig.texlab.setup {
		settings = {
			texlab = {
				build = {
					executable = 'latexmk',
					args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' },
					onSave = false,
					forwardSearchAfter = true,
				},
				forwardSearch = {
					executable = "zathura",
					args = { "--synctex-forward", "%l:1:%f", "%p" }
				}
			}
		}
	}
end

local function setup_lsp()
	local lspconfig = require('lspconfig')

	-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	-- lspconfig.pyright.setup {}
	-- lspconfig.tsserver.setup {}
	-- lspconfig.bashls.setup {}()
	setup_texlab(lspconfig)
	setup_py_lsp(lspconfig)
	setup_clangd(lspconfig)
	setup_rust_analyzer(lspconfig)
	setup_lua_ls(lspconfig)
end

local function setup_keybinding()
	local keymap = vim.keymap.set
	keymap("n", "gd", vim.lsp.buf.definition)
	keymap("n", "gD", vim.lsp.buf.declaration)
	keymap("n", "gr", vim.lsp.buf.references)
	keymap("n", "<leader>gk", vim.lsp.buf.hover)
	keymap("n", "<leader>gr", vim.lsp.buf.rename)
	keymap("n", "<leader>gd", vim.lsp.buf.implementation)
	keymap("n", "<leader>gt", vim.lsp.buf.type_definition)
	keymap("n", "<leader>gT", vim.lsp.buf.typehierarchy)
	keymap("n", "<leader>gx", vim.lsp.buf.code_action)
	keymap("n", "<leader>gi", vim.lsp.buf.incoming_calls)
	keymap("n", "<leader>go", vim.lsp.buf.outgoing_calls)
	keymap("n", "<leader>gf", vim.lsp.buf.format)
	keymap("v", "<leader>gf", function()
		vim.lsp.buf.format()
		vim.api.nvim_input('<Esc>')
	end)
	keymap("n", "<leader>gg", function()
		local clients = vim.lsp.get_active_clients()
		for _, client in ipairs(clients) do
			if client.name == "texlab" then
				vim.api.nvim_command('TexlabBuild')
				return
			end
		end
		vim.lsp.buf.format()
		vim.api.nvim_command('write')
	end)
	keymap("n", "]e", vim.diagnostic.goto_next)
	keymap("n", "[e", vim.diagnostic.goto_prev)

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
