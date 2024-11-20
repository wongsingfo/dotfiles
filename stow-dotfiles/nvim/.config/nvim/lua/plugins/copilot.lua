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
	},
	config = function()
		local openai_key_file = vim.fn.expand("$HOME/.llmkeys/YI_KEY")

		require 'avante'.setup {
			provider = "openai",
			openai = {
				-- endpoint = "https://api.xiaoai.plus/v1",
				endpoint = "https://api.lingyiwanwu.com/v1",
				-- model = "claude-3-5-sonnet-20241022",
				-- model = "gpt-4o-2024-08-06",
				model = "yi-lightning",
				api_key_name = "cmd:cat " .. openai_key_file,
				temperature = 0,
				max_tokens = 4096,
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
		}

		-- vim.api.nvim_set_hl(0, 'AvanteDiffAdd', { bg = "#002800" })
		-- vim.api.nvim_set_hl(0, 'AvanteDiffText', { bg = "#280000" })
		-- vim.api.nvim_set_hl(0, 'AvanteConflictIncoming', { bg = "#400000" })
		-- vim.api.nvim_set_hl(0, 'AvanteConflictCurrent', { bg = "#280000" })
	end
}
