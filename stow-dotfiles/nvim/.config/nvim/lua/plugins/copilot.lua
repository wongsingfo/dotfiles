return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	opts = {},
	build = "make",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		{
			"grapp-dev/nui-components.nvim",
			dependencies = {
				"MunifTanjim/nui.nvim"
			}
		},
		"nvim-lua/plenary.nvim",
		-- "MeanderingProgrammer/render-markdown.nvim",
	},
	config = {
		provider = "openai",
		openai = {
			endpoint = "https://api.xiaoai.plus",
			model = "gpt-4o",
			temperature = 0,
			max_tokens = 4096,
		},
		highlights = {
			diff = {
				current = "DiffText", -- need have background color
				incoming = "DiffAdd", -- need have background color
			},
		},
	},
}
