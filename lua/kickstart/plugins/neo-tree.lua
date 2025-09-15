-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    -- toggle the tree open/closed
    { '<leader>E', ':Neotree toggle<CR>', desc = 'NeoTree toggle', silent = true },

    -- focus tree / focus back
    {
      '<leader>e',
      function()
        local function find_neotree_win()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'neo-tree' then
              return win
            end
          end
        end
        if not vim.g._neotree_prev_win or not vim.api.nvim_win_is_valid(vim.g._neotree_prev_win) then
          vim.g._neotree_prev_win = vim.api.nvim_get_current_win()
        end
        local ntwin = find_neotree_win()
        if ntwin and vim.api.nvim_get_current_win() ~= ntwin then
          vim.api.nvim_set_current_win(ntwin)
        elseif ntwin and vim.api.nvim_get_current_win() == ntwin then
          if vim.g._neotree_prev_win and vim.api.nvim_win_is_valid(vim.g._neotree_prev_win) then
            vim.api.nvim_set_current_win(vim.g._neotree_prev_win)
          else
            vim.cmd 'wincmd p'
          end
        else
          vim.cmd 'Neotree toggle'
          vim.schedule(function()
            local w = find_neotree_win()
            if w then
              vim.api.nvim_set_current_win(w)
            end
          end)
        end
      end,
      desc = 'Focus NeoTree / return',
    },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
