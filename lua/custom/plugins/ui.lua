return {
  -- Icons for everything
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Beautiful statusline
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = { theme = 'auto', globalstatus = true, section_separators = '', component_separators = '' },
    },
  },

  -- Buffers as tabs
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    opts = {
      options = { diagnostics = 'nvim_lsp', separator_style = 'slant' },
    },
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = 'VeryLazy',
    opts = { scope = { enabled = true }, indent = { char = '│' } },
  },

  -- Nicer UI: messages, cmdline, popups
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = { 'rcarriga/nvim-notify', 'MunifTanjim/nui.nvim' },
    opts = { presets = { lsp_doc_border = true } },
    config = function(_, opts)
      require('noice').setup(opts)
      vim.notify = require 'notify'
    end,
  },

  -- Better input/select UIs
  { 'stevearc/dressing.nvim', event = 'VeryLazy' },

  -- LSP progress spinner
  { 'j-hui/fidget.nvim', tag = 'legacy', event = 'LspAttach', opts = {} },

  -- Git signs in gutter
  { 'lewis6991/gitsigns.nvim', event = 'BufReadPre', opts = {} },

  -- Rounded borders for LSP/diagnostics popups
  --{
  --  'neovim/nvim-lspconfig',
  --  opts = {},
  --  config = function()
  --    local border = 'rounded'
  --    vim.diagnostic.config { float = { border = border } }
  --    local handlers = vim.lsp.handlers
  --    handlers['textDocument/hover'] = vim.lsp.with(handlers.hover, { border = border })
  --    handlers['textDocument/signatureHelp'] = vim.lsp.with(handlers.signature_help, { border = border })
  --  end,
  --},
}
