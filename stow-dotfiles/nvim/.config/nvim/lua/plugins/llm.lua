return {
	"mozanunal/sllm.nvim",
	config = function()
		local wk = require("which-key")
		wk.add({ "<leader>s", group="llm" })

		require("sllm").setup({
			default_model = "default",
		})
	end,
}
