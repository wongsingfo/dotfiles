local function setup_shortcut()
	local predefined_prompt =
	"Please act as my writing mentor to refine the selected text for submission to a top-tier computer science conference. Make the content accessible to most people, use plain word and make it easy to understand. Try to avoid using fancy words. Strengthen the logic and ensure it aligns with academic standards."
	local edit = require("avante.api").edit
	vim.api.nvim_create_autocmd("User", {
		pattern = "AvanteCustomWriting",
		callback = function()
			edit(predefined_prompt)
		end
	})
	vim.keymap.set("v", "<leader>aw",
		function()
			vim.api.nvim_exec_autocmds("User", { pattern = "AvanteCustomWriting" })
		end,
		{
			desc = "avante: custom writing"
		})
end

local function fix_highlight()
	-- vim.api.nvim_set_hl(0, 'AvanteDiffAdd', { bg = "#002800" })
	-- vim.api.nvim_set_hl(0, 'AvanteDiffText', { bg = "#280000" })
	-- Set highlight groups for Avante conflicts
	vim.api.nvim_set_hl(0, 'AvanteConflictIncoming', { bg = "#002800" })
	vim.api.nvim_set_hl(0, 'AvanteConflictCurrent', { bg = "#280000" })
end

return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	enabled = false,
	version = false, -- Never set this value to "*"! Never!
	build = "make",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"hrsh7th/nvim-cmp",
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
			provider = "openrouter-gpt",
			auto_suggestions_provider = "openrouter-gpt",
			cursor_applying_provider = "openrouter-gpt",

			hints = { enabled = false },
			vendors = {
				["user-default"] = {
					endpoint = "https://" .. api_host .. '/v1',
					model = model,
					api_key_name = "cmd:cat " .. openai_key_file,
					temperature = 0,
					max_tokens = 4096,
				},
				["siliconflow-qwen"] = {
					__inherited_from = 'openai',
					api_key_name = "cmd:cat " .. vim.fn.expand("$HOME/.llmkeys/api.siliconflow.cn"),
					endpoint = 'https://api.siliconflow.cn/v1',
					model = 'Qwen/Qwen2.5-Coder-32B-Instruct',
				},
				["openrouter-sonnet"] = {
					__inherited_from = 'claude',
					endpoint = 'https://openrouter.ai/api/v1',
					api_key_name = "cmd:cat " .. vim.fn.expand("$HOME/.llmkeys/openrouter.ai"),
					model = 'anthropic/claude-3.7-sonnet',
					disable_tools = true,
				},
				["openrouter-gpt"] = {
					__inherited_from = 'openai',
					endpoint = 'https://openrouter.ai/api/v1',
					api_key_name = "cmd:cat " .. vim.fn.expand("$HOME/.llmkeys/openrouter.ai"),
					model = 'openai/gpt-4o-mini',
					disable_tools = true,
				},
				["openrouter-gemini"] = {
					__inherited_from = 'gemini',
					endpoint = 'https://openrouter.ai/api/v1',
					api_key_name = "cmd:cat " .. vim.fn.expand("$HOME/.llmkeys/openrouter.ai"),
					model = 'google/gemini-2.0-flash-001',
					disable_tools = true,
				},
			},

			mappings = {
				submit = {
					normal = "<CR>",
					insert = "<C-m>",
				},
			}
		}

		-- fix_highlight()
		setup_shortcut()
	end
}
