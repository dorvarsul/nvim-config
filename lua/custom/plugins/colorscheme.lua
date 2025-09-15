return {
  {
    'rebelot/kanagawa.nvim',
    priority = 1000, -- load first so UI plugins pick it up
    lazy = false,
    init = function()
      vim.opt.termguicolors = true
      vim.opt.background = 'dark'
    end,
    config = function()
      -- optional: choose a style (wave, dragon, lotus)
      require('kanagawa').setup {
        theme = 'wave', -- "wave" | "dragon" | "lotus"
        background = { dark = 'wave', light = 'lotus' },
      }
      vim.cmd 'colorscheme kanagawa-wave'
    end,
  },
}
