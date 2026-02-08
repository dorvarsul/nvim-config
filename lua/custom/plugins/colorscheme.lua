return {
  {
    'Mofiqul/dracula.nvim',
    priority = 1000, -- load first so UI plugins pick it up
    lazy = false,
    init = function()
      vim.opt.termguicolors = true
      vim.opt.background = 'dark'
    end,
    config = function()
      require('dracula').setup {}
      vim.cmd 'colorscheme dracula'
    end,
  },
}
