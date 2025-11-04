-- LSP Plugins
return {
  {
    -- Lua LSP helper for Neovim configs/plugins
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' }, -- load early

    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },

    config = function()
      ------------------------------------------------------------------------
      -- SAFETY SHIM: flatten any accidental table args to vim.fs.joinpath
      ------------------------------------------------------------------------
      do
        local orig = vim.fs.joinpath
        vim.fs.joinpath = function(...)
          local flat = {}
          local function push(v)
            if type(v) == 'table' then
              for _, x in ipairs(v) do
                push(x)
              end
            elseif v ~= nil then
              table.insert(flat, v)
            end
          end
          for i = 1, select('#', ...) do
            push(select(i, ...))
          end
          return orig(unpack(flat))
        end
      end

      ------------------------------------------------------------------------
      -- Diagnostics UI
      ------------------------------------------------------------------------
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(d)
            return d.message
          end,
        },
      }

      ------------------------------------------------------------------------
      -- Capabilities + common on_attach (and non-file guard)
      ------------------------------------------------------------------------
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local function on_attach_common(client, bufnr)
        if vim.bo[bufnr].buftype ~= '' then
          vim.schedule(function()
            pcall(function()
              client.stop()
            end)
          end)
          return
        end

        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
        map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

        local function supports(client, method, b)
          if vim.fn.has 'nvim-0.11' == 1 then
            return client:supports_method(method, b)
          else
            return client.supports_method(method, { bufnr = b })
          end
        end
        if supports(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, bufnr) then
          local hl = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { buffer = bufnr, group = hl, callback = vim.lsp.buf.document_highlight })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { buffer = bufnr, group = hl, callback = vim.lsp.buf.clear_references })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(ev)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = ev.buf }
            end,
          })
        end
        if supports(client, vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
          end, '[T]oggle Inlay [H]ints')
        end
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            on_attach_common(client, event.buf)
          end
        end,
      })

      ------------------------------------------------------------------------
      -- Servers
      ------------------------------------------------------------------------
      local lspconfig = require 'lspconfig'
      local util = require 'lspconfig.util'
      local javafx_path = '/home/dorvarsul/Desktop/javafx/javafx-sdk-21.0.9'

      local servers = {
        ts_ls = {
          autostart = true,
          filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
          },
          root_dir = function(fname)
            return util.root_pattern('package.json', 'tsconfig.json', 'jsconfig.json', 'tsconfig.base.json', '.git')(fname) or util.path.dirname(fname)
          end,
          single_file_support = true,
          on_attach = on_attach_common,
        },

        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
          on_attach = on_attach_common,
        },

        pyright = {},
        html = {},
        cssls = {},
        clangd = {},
        jdtls = {},
      }

      -- Ensure tools/servers installed
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'typescript-language-server',
        'pyright',
        'html-lsp',
        'cssls',
        'clangd',
        'jdtls',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Mason-lspconfig handler: set up everything with our table
      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            lspconfig[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
