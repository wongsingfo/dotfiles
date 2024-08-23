return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	opts = {},
	build = "make",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		-- The below is optional, make sure to setup it properly if you have lazy=true
		-- {
		-- 	'MeanderingProgrammer/render-markdown.nvim',
		-- 	opts = {
		-- 		file_types = { "markdown", "Avante" },
		-- 	},
		-- 	ft = { "markdown", "Avante" },
		-- }
	},
	config = function()
		local openai_key_file = vim.fn.expand("$HOME/.config/XIAOAI_KEY")
		if vim.fn.filereadable(openai_key_file) == 1 then
			vim.env.OPENAI_API_KEY = vim.fn.readfile(openai_key_file)[1] or nil
		end
		require 'avante'.setup {
			provider = "openai",
			openai = {
				endpoint = "https://api.xiaoai.plus",
				model = "gpt-4o",
				temperature = 0,
				max_tokens = 4096,
			},
			mappings = {
				ask = "<leader>aa",
				edit = "<leader>ae",
				refresh = "<leader>ar",
				--- @class AvanteConflictMappings
				diff = {
					ours = "co",
					theirs = "ct",
					none = "c0",
					both = "cb",
					next = "]x",
					prev = "[x",
				},
				jump = {
					next = "]]",
					prev = "[[",
				},
			},
			hints = { enabled = true },
			windows = {
				wrap = true, -- similar to vim.o.wrap
				width = 40, -- default % based on available width
				sidebar_header = {
					align = "center", -- left, center, right for title
					rounded = false,
				},
			},
			highlights = {
				diff = {
					current = "DiffText",
					incoming = "DiffAdd",
				},
			},
			--- @class AvanteConflictUserConfig
			diff = {
				debug = false,
				autojump = true,
				---@type string | fun(): any
				list_opener = "copen",
			},
		}
	end
}
