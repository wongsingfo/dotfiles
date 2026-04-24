local vim = vim

-- Plugin management with vim.pack (requires nvim >= 0.12).
-- Reference: https://neovim.io/doc/user/pack/
--
-- Build-step plugins (markdown-preview npm install, telescope-fzf-native
-- `make`, mason `:MasonUpdate`) are handled by the PackChanged autocmd
-- below.

vim.pack.add({
	-- Colorscheme (load early so messages are themed)
	{ src = "https://github.com/rebelot/kanagawa.nvim" },

	-- Treesitter and its companion plugins.
	-- Pin nvim-treesitter to v0.10.0 (last v0.x stable) — v1.0 is a full
	-- rewrite that drops the `nvim-treesitter.configs` module our config
	-- uses. Drop `playground` (replaced by built-in `:InspectTree` in
	-- nvim 0.12) and `nvim-treesitter-textobjects` (v1.0 changed module
	-- layout and API, would need a separate migration).
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "v0.10.0" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },

	-- Telescope and its hard deps
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },

	-- LSP
	{ src = "https://github.com/williamboman/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },

	-- mini.nvim suite
	{ src = "https://github.com/nvim-mini/mini.nvim" },

	-- UI / navigation
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/stevearc/aerial.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/ojroques/nvim-osc52" },

	-- File / file-type integrations
	{ src = "https://github.com/iamcco/markdown-preview.nvim" },
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },

	-- Small utilities
	{ src = "https://github.com/nmac427/guess-indent.nvim" },
	{ src = "https://github.com/chentoast/marks.nvim" },
	{ src = "https://github.com/kevinhwang91/nvim-bqf" },
	{ src = "https://github.com/tpope/vim-surround" },
})

-- Build steps for plugins that need post-install compilation.
-- Triggered on first install and on every update.
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("PluginsBuildSteps", { clear = true }),
	callback = function(args)
		local data = args.data
		if data.kind ~= "install" and data.kind ~= "update" then
			return
		end
		local name = data.spec.name
		local path = data.spec.path or data.path
		if name == "telescope-fzf-native.nvim" then
			vim.system({ "make" }, { cwd = path }):wait()
		elseif name == "markdown-preview.nvim" then
			vim.system({ "npm", "install" }, { cwd = path .. "/app" }):wait()
		elseif name == "mason.nvim" then
			pcall(vim.cmd, "MasonUpdate")
		end
	end,
})

-- Setup individual plugins.  which-key must come before git (gitsigns.nvim
-- calls wk.add()), and treesitter must come before any plugin that depends
-- on its parsers.
require("plugins.colorscheme")
require("plugins.mini")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.telescope")
require("plugins.whichkey")
require("plugins.git")
require("plugins.symboltable")
require("plugins.osc52")
require("plugins.markdown")
require("plugins.yazi")
require("plugins.typst")
require("plugins.utility")
