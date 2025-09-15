-- === Bottom-split terminal toggle on <C-r> ===
-- Notes:
--  - Opens a terminal in a bottom split (height 12), starts in insert/terminal mode.
--  - Press <C-r> again to hide the terminal window (job keeps running in background).
--  - Re-press <C-r> to bring it back.
--  - Overrides normal-mode redo (<C-r>). If you want redo, remap it elsewhere or pick a different key here.

return {
  {
    'nvim-lua/plenary.nvim', -- harmless anchor
    lazy = false,
    priority = 1000,
    config = function()
      local term = { buf = nil }
      local function term_is_visible()
        if not term.buf or not vim.api.nvim_buf_is_valid(term.buf) then
          return false
        end
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == term.buf then
            return true, win
          end
        end
        return false
      end
      local function toggle_bottom_terminal()
        local visible, win = term_is_visible()
        if visible then
          vim.api.nvim_win_close(win, false)
          return
        end
        if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
          vim.cmd 'botright split'
          vim.api.nvim_win_set_buf(0, term.buf)
          vim.cmd 'resize 12'
          vim.cmd 'startinsert'
          return
        end
        vim.cmd 'botright split | resize 12 | terminal'
        term.buf = vim.api.nvim_get_current_buf()
        vim.bo[term.buf].bufhidden = 'hide'
        vim.cmd 'startinsert'
      end
      vim.keymap.set({ 'n', 't' }, '<C-r>', toggle_bottom_terminal, { desc = 'Toggle bottom terminal', noremap = true, silent = true })
    end,
  },
}
