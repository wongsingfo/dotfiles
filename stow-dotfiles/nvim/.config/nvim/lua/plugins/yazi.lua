return {
  "mikavilpas/yazi.nvim",
  -- event = "VeryLazy",
  cmd = "Yazi",
  keys = {
    {
      "-",
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
  },
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    -- keymaps = {
    --   show_help = '<f1>',
    -- },
  },
}
