local function setup_clangd()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	---@diagnostic disable-next-line: inject-field
	capabilities.offsetEncoding = 'utf-8'
	vim.lsp.config.clangd = {
		capabilities = capabilities
	}
end
local function setup_rust_analyzer()
	vim.lsp.config.rust_analyzer = {
		-- Server-specific settings. See `:help lspconfig-setup`
		settings = {
			['rust-analyzer'] = {},
		},
	}
end

local function setup_lua_ls()
	vim.lsp.config('lua_ls', {
		on_init = function(client)
			if client.workspace_folders then
				local path = client.workspace_folders[1].name
				if
				    path ~= vim.fn.stdpath('config')
				    and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
				then
					return
				end
			end

			client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
				runtime = {
					-- Tell the language server which version of Lua you're using (most
					-- likely LuaJIT in the case of Neovim)
					version = 'LuaJIT',
					-- Tell the language server how to find Lua modules same way as Neovim
					-- (see `:h lua-module-load`)
					path = {
						'lua/?.lua',
						'lua/?/init.lua',
					},
				},
				-- Make the server aware of Neovim runtime files
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME
						-- Depending on the usage, you might want to add additional paths
						-- here.
						-- '${3rd}/luv/library'
						-- '${3rd}/busted/library'
					}
					-- Or pull in all of 'runtimepath'.
					-- NOTE: this is a lot slower and will cause issues when working on
					-- your own configuration.
					-- See https://github.com/neovim/nvim-lspconfig/issues/3189
					-- library = {
					--   vim.api.nvim_get_runtime_file('', true),
					-- }
				}
			})
		end,
		settings = {
			Lua = {}
		}
	})
end

local function setup_pylsp()
	vim.lsp.config.pylsp = {
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

local function setup_texlab()
	vim.lsp.config.texlab = {
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
	-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
	-- lspconfig.pyright.setup {}
	-- lspconfig.tsserver.setup {}
	-- lspconfig.bashls.setup {}()
	vim.lsp.enable('gopls')
	setup_texlab()
	setup_pylsp()
	setup_clangd()
	setup_rust_analyzer()
	setup_lua_ls()

	-- Native LSP completion (Neovim 0.11+)
	if vim.lsp.completion then
		vim.opt.completeopt = { "menu", "menuone", "noselect" }
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.supports_method("textDocument/completion") then
					vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
				end
			end,
		})
	end
end

local function setup_keybinding()
	local keymap = vim.keymap.set
	keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
	keymap("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
	keymap("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
	keymap("n", "<leader>gk", vim.lsp.buf.hover, { desc = "Show hover information" })
	keymap("n", "<leader>gr", vim.lsp.buf.rename, { desc = "Rename symbol" })
	keymap("n", "<leader>gd", vim.lsp.buf.implementation, { desc = "Go to implementation" })
	keymap("n", "<leader>gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
	keymap("n", "<leader>gT", vim.lsp.buf.typehierarchy, { desc = "Show type hierarchy" })
	keymap("n", "<leader>gx", vim.lsp.buf.code_action, { desc = "Show code actions" })
	keymap("n", "<leader>gi", vim.lsp.buf.incoming_calls, { desc = "Show incoming calls" })
	keymap("n", "<leader>go", vim.lsp.buf.outgoing_calls, { desc = "Show outgoing calls" })
	keymap("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format document" })
	keymap("v", "<leader>gf", function()
		vim.lsp.buf.format()
		vim.api.nvim_input('<Esc>')
	end, { desc = "Format selection" })
	keymap("n", "<leader>gg", function()
		vim.lsp.buf.format()
		vim.api.nvim_command('write')
		local clients = vim.lsp.get_clients()
		for _, client in ipairs(clients) do
			if client.name == "texlab" then
				vim.api.nvim_command("LspTexlabBuild")
				return
			end
		end
	end, { desc = "Format and save" })
	keymap("n", "]e", function()
		vim.diagnostic.jump({ count = 1 })
	end, { desc = "Go to next diagnostic" })
	keymap("n", "[e", function()
		vim.diagnostic.jump({ count = -1 })
	end, { desc = "Go to previous diagnostic" })

	keymap("n", "<leader>gh", "<cmd>ClangdSwitchSourceHeader<CR>")
end

local function setup_win_border()
	-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
	-- To instead override globally
	local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
	---@diagnostic disable-next-line: duplicate-set-field
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig_util_open_floating_preview(contents, syntax, opts, ...)
	end
end

return {
	{
		"neovim/nvim-lspconfig",
		cmd = "LspStart",
		config = function()
			setup_lsp()
			setup_keybinding()
			setup_win_border()
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
}
