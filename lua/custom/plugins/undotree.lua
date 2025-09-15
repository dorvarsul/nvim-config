return {
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      {
        '<leader>u',
        function()
          -- helper: find an existing undotree window (by filetype)
          local function find_undotree_win()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == 'undotree' then
                return win
              end
            end
          end

          -- keep previous window to restore when closing
          if not vim.g._undotree_prev_win or not vim.api.nvim_win_is_valid(vim.g._undotree_prev_win) then
            vim.g._undotree_prev_win = vim.api.nvim_get_current_win()
          end

          local undowin = find_undotree_win()
          if undowin then
            -- already open -> close and return to previous window
            vim.cmd.UndotreeToggle()
            if vim.g._undotree_prev_win and vim.api.nvim_win_is_valid(vim.g._undotree_prev_win) then
              pcall(vim.api.nvim_set_current_win, vim.g._undotree_prev_win)
            else
              vim.cmd 'wincmd p'
            end
            vim.g._undotree_prev_win = nil
          else
            -- closed -> open and focus it
            vim.cmd.UndotreeToggle()
            vim.schedule(function()
              local w = find_undotree_win()
              if w then
                vim.api.nvim_set_current_win(w)
              end
            end)
          end
        end,
        desc = 'Toggle UndoTree (focus on open, restore on close)',
      },
    },
    -- Optional: make the tree open on the right side (feel free to remove)
    init = function()
      vim.g.undotree_WindowLayout = 3 -- 2=left, 3=right
    end,
  },
}
