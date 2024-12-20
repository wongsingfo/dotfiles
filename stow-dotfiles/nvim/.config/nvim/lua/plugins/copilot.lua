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
		-- Get the API host from the file
		local host_file_path = vim.fn.expand("$HOME/.llmkeys/HOST")
		local model_file_path = vim.fn.expand("$HOME/.llmkeys/MODEL")

		local function read_file_trim_whitespace(file_path)
			local success, file = pcall(io.open, file_path, "r")
			if success and file then
				local content = file:read("*all"):gsub("%s+", "")
				file:close()
				return content
			else
				vim.notify("Failed to read file: " .. file_path, vim.log.levels.ERROR)
				return nil
			end
		end

		local api_host = read_file_trim_whitespace(host_file_path)
		if not api_host then
			return
		end

		local model = read_file_trim_whitespace(model_file_path) or "gpt-4o"
		if not model then
			return
		end

		local openai_key_file = vim.fn.expand("$HOME/.llmkeys/" .. api_host)

		-- Setup Avante with OpenAI configuration using the model from the file
		require('avante').setup {
			provider = "openai",
			openai = {
				endpoint = "https://" .. api_host .. '/v1',
				model = model,
				api_key_name = "cmd:cat " .. openai_key_file,
				temperature = 0,
				max_tokens = 4096,
			},
			hints = { enabled = false },
		}

		-- vim.api.nvim_set_hl(0, 'AvanteDiffAdd', { bg = "#002800" })
		-- vim.api.nvim_set_hl(0, 'AvanteDiffText', { bg = "#280000" })
		-- Set highlight groups for Avante conflicts
		vim.api.nvim_set_hl(0, 'AvanteConflictIncoming', { bg = "#002800" })
		vim.api.nvim_set_hl(0, 'AvanteConflictCurrent', { bg = "#280000" })
	end
}
