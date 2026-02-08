return {
  -- 1. The Core Engine (Unchanged, keeps your tab completion)
  {
    'github/copilot.vim',
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.keymap.set('i', '<leader><Tab>', 'copilot#Accept("<CR>")', { silent = true, expr = true, replace_keycodes = false })
    end,
  },

  -- 2. The Chat Interface (Refactored)
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' },
      { 'nvim-lua/plenary.nvim' },
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      debug = false,
      model = 'gpt-4o', -- Your preferred model

      -- 1. Classic Vim Layout: Vertical Split
      window = {
        layout = 'vertical', -- 'float', 'vertical', 'horizontal', 'replace'
        width = 0.4, -- Percentage of screen width
        height = 0.4,
        relative = 'editor',
      },

      -- Default context
      context = 'buffers',
    },

    config = function(_, opts)
      local chat = require 'CopilotChat'
      local select = require 'CopilotChat.select'

      chat.setup(opts)

      -- Helper to create mappings
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = 'AI: ' .. desc, noremap = true, silent = true })
      end

      -- --- KEYMAPPINGS --- --

      -- 1. TOGGLE CHAT
      map({ 'n', 'v' }, '<leader>aa', function()
        chat.toggle()
      end, 'Toggle Chat')

      -- 2. EXPLAIN (Visual Selection)
      map('v', '<leader>ae', function()
        chat.ask('/explain You are a senior software developer, Explain how this code works.', { selection = select.visual })
      end, 'Explain Selection')

      -- 3. REFACTOR (Interactive)
      -- Opens chat, asks for instruction, shows diff. Safer than auto-replace.
      map('v', '<leader>ar', function()
        local input = vim.fn.input 'Refactor goal: '
        if input ~= '' then
          chat.ask(input, { selection = select.visual })
        end
      end, 'Refactor Selection')

      -- 4. FIX / DEBUG (Diagnostics)
      -- Fixes the error under your cursor (LSP/Linter errors)
      map('n', '<leader>ad', function()
        chat.ask('/fix Fix the diagnostic error at cursor.', { selection = select.visual })
      end, 'Fix Diagnostic at Cursor')

      -- 5. DEBUG (External Terminal)
      -- Copy an error from your terminal, then press this.
      -- It reads your system clipboard (+) and the current buffer.
      map('n', '<leader>at', function()
        local clip_content = vim.fn.getreg '+'
        chat.ask('Fix this error from my terminal output:\n\n' .. clip_content, {
          selection = select.buffer,
        })
      end, 'Fix Error from Clipboard')

      -- 6. EXPLAIN PROJECT (All Listed Buffers)
      -- This sends the content of ALL listed buffers to the AI for a full architecture review.
      map('n', '<leader>ap', function()
        -- We manually require the module inside the function to avoid startup errors
        require('CopilotChat').ask(
          '#buffer:listed /explain Act as a senior software architect. Provide a high-level summary, module interactions, and patterns.',
          { selection = false }
        )
      end, 'Explain Project Architecture (Listed Buffers)')

      -- 7. DEEP TECHNICAL ANALYSIS (All Open Buffers)
      -- Lists functions, signatures, inputs/outputs, and step-by-step logic.
      map('n', '<leader>af', function()
        require('CopilotChat').ask(
          -- The prompt explicitly asks for technical details on all buffers
          '#buffer:listed /explain Analyze the code technically. For each major component/function in the open buffers, provide: \n1. Function Signature (Inputs/Outputs) \n2. Logic Flow (Step-by-step) \n3. Edge Cases or Constraints.',
          { selection = false }
        )
      end, 'Deep Technical Analysis (Functions & I/O)')
    end,
  },
}
