return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	build = "make",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
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

		vim.api.nvim_set_hl(0, 'AvanteDiffText', { bg = "#280000" })
		vim.api.nvim_set_hl(0, 'AvanteDiffAdd', { bg = "#002800" })

		require 'avante'.setup {
			provider = "openai",
			openai = {
				endpoint = "https://api.xiaoai.plus/v1",
				-- model = "claude-3-5-sonnet-20240620",
				model = "gpt-4o-2024-08-06",
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
				toggle = {
					debug = "<leader>ad",
					hint = "<leader>ah",
				},
			},
			hints = { enabled = false },
			windows = {
				wrap = true, -- similar to vim.o.wrap
				position = "right", -- the position of the sidebar
				width = 40, -- default % based on available width
				sidebar_header = {
					align = "center", -- left, center, right for title
					rounded = false,
				},
			},
			highlights = {
				diff = {
					current = "AvanteDiffText",
					incoming = "AvanteDiffAdd",
				},
			},
			--- @class AvanteConflictUserConfig
			diff = {
				autojump = true,
				---@type string | fun(): any
				list_opener = "copen",
			},
		}
	end
}
