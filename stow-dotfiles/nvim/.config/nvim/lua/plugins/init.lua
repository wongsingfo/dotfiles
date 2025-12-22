local vim = vim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- check if env variable "GH_PROXY" is set
local use_ghproxy = false
if vim.env.GH_PROXY then
	use_ghproxy = true
end

local lazy_url = "https://github.com/folke/lazy.nvim.git"
local lazy_url_format = "https://github.com/%s.git"
if use_ghproxy then
	local ghproxy_url = "https://ghproxy.org/"
	lazy_url = ghproxy_url .. lazy_url
	lazy_url_format = ghproxy_url .. lazy_url_format
end

-- If lazy.nvim is not installed, install it
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local system_obj = vim.system({
		"git",
		"clone",
		"--filter=blob:none",
		lazy_url,
		"--branch=stable", -- latest stable release
		lazypath,
	})
	local rc = system_obj:wait()
	if rc ~= 0 then
		error("git clone failed, set env variable GH_PROXY=1 to use ghproxy")
	end
end

vim.opt.rtp:prepend(lazypath)

-- https://github.com/folke/lazy.nvim#-plugin-spec
require('lazy').setup {
	git = {
		url_format = lazy_url_format,
	},

	---------------------------
	-- List all plugins here --
	---------------------------

	-- More Key
	"tomtom/tcomment_vim",
	"tpope/vim-surround",

	-- Utility
	{ "nmac427/guess-indent.nvim", config = true },
	{ "chentoast/marks.nvim",      config = true },
	"kevinhwang91/nvim-bqf", -- make Neovim's quickfix window better

	require("plugins.yazi"),
	require("plugins.whichkey"),
	require("plugins.git"),
	require("plugins.osc52"),
	require("plugins.treesitter"),
	require("plugins.lsp"),
	require("plugins.cmp"),
	require("plugins.colorscheme"),
	require("plugins.symboltable"),
	require("plugins.llm"),
	require("plugins.mini"),
	require("plugins.opencode"),
	require("plugins.telescope"),
	-- require("plugins.avante"),
}
