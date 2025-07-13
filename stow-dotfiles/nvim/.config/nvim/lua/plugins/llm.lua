return {
	"mozanunal/sllm.nvim",
	config = function()
		require("sllm").setup({
			default_model = "default",
		})
	end,
}
