return {
  -- 1. The Core Engine (Ghost Text)
  {
    'github/copilot.vim',
    config = function()
      -- Disable default tab so it doesn't conflict
      vim.g.copilot_no_tab_map = true
      -- Map <leader><Tab> in Insert mode to accept the suggestion
      -- If your leader is <Space>, you will press: Space then Tab
      vim.keymap.set('i', '<leader><Tab>', 'copilot#Accept("<CR>")', {
        silent = true,
        expr = true,
        replace_keycodes = false,
      })
    end,
  },

  -- 2. The Chat Interface
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' },
      { 'nvim-lua/plenary.nvim' },
    },
    build = 'make tiktoken',
    opts = {
      debug = false,
      model = 'gpt-4.1', -- Use a '0x' model to save your 300 monthly credits
    },
    keys = {
      -- 1. Explain highlighted code
      { '<leader>ce', '<cmd>CopilotChatExplain<cr>', mode = 'v', desc = 'CopilotChat - Explain code' },

      -- 2. Direct Refactor (Applies changes to the code)
      {
        '<leader>cf',
        function()
          local input = vim.fn.input 'Refactor instruction: '
          if input ~= '' then
            require('CopilotChat').ask(input, {
              -- This tells the AI to treat the output as a direct replacement
              selection = require('CopilotChat.select').visual,
              window = {
                layout = 'float', -- Progress appears in a small popup
                title = 'Refactoring...',
              },
            })
          end
        end,
        mode = 'v',
        desc = 'CopilotChat - Refactor code (Direct)',
      },

      -- 3. Explain Project (Uses all open buffers)
      {
        '<leader>cpe',
        function()
          require('CopilotChat').ask(
            '#buffer:listed /explain Act as a senior software architect. I am going to provide code. please analyze them and provide 1.A high level summary of what this code does, 2. Identify the main modules, classes or functions and how they interact, 3.Explain how data enters the system, moves through these components and where it ends up, 4.Identify any specific patterns used',
            {
              selection = false, -- Ignore current cursor/highlight
            }
          )
        end,
        desc = 'CopilotChat - Explain Project Architecture',
      },
      --4. Understand how the code does what it does
      {
        '<leader>cpf',
        function()
          require('CopilotChat').ask(
            '#buffer:listed /explain Act as a lead developer, walk me through the logic step by step, for each significant function or block, explain: 1. The logical purpose, 2. How it achieves this purpose, 3. What are the inputs / outputs, 4. How it connects to the other parts of the code',
            {
              selection = false,
            }
          )
        end,
        desc = 'CopilotChat - Explain how the code works step by step',
      },
      -- 5. Debug Console/Messages
      {
        '<leader>cpd',
        function()
          -- Capture the last 20 lines of the Neovim message history
          local messages = vim.fn.execute 'messages'
          local lines = vim.split(messages, '\n')
          local last_output = table.concat(vim.list_slice(lines, #lines - 20), '\n')

          if last_output ~= '' then
            require('CopilotChat').ask(
              'I am seeing this console output/error. Can you explain what is happening and how to fix it?\n\nOutput:\n' .. last_output,
              {
                selection = false, -- Don't use current code selection
              }
            )
          else
            print 'No console output found to debug!'
          end
        end,
        desc = 'CopilotChat - Debug latest console output',
      },
      -- 6. Open Chat (Standard)
      { '<leader>cc', '<cmd>CopilotChat<cr>', desc = 'CopilotChat - Open chat' },
    },
  },
}
