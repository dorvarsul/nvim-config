return {
  'neovim/nvim-lspconfig',
  config = function()
    local lspconfig = require 'lspconfig'
    local util = require 'lspconfig.util'
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if cmp_nvim_lsp_ok then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    local javafx_path = '/home/dorvarsul/Desktop/javafx/javafx-sdk-21.0.9'
    local mason_jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
    local launcher_jar = vim.fn.glob(mason_jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
    local config_dir = mason_jdtls_path .. '/config_linux'

    -- Use a dedicated workspace path outside source tree
    local workspace_dir = vim.fn.expand '~/.cache/jdtls-workspace/advanced-java-20554'

    -- Helper list for project root detection files
    local root_files = { '.git', 'pom.xml', 'build.gradle', '.project', '.classpath' }

    lspconfig.jdtls.setup {
      cmd = {
        'java',
        '-Xms1g',
        '--add-modules=ALL-SYSTEM,javafx.controls,javafx.fxml',
        '--module-path=' .. javafx_path .. '/lib',
        '--add-opens=java.base/java.util=ALL-UNNAMED',
        '--add-opens=java.base/java.lang=ALL-UNNAMED',
        '-jar',
        launcher_jar,
        '-configuration',
        config_dir,
        '-data',
        workspace_dir,
      },
      root_dir = function(fname)
        return util.root_pattern(unpack(root_files))(fname) or util.path.dirname(fname)
      end,
      on_attach = function(client, bufnr)
        -- Your on_attach_common or custom on_attach logic
      end,
      capabilities = capabilities,
      settings = {
        java = {
          project = {
            referencedLibraries = { javafx_path .. '/lib/*.jar' },
          },
          format = {
            enabled = true,
          },
        },
      },
      init_options = {
        bundles = {},
      },
    }
  end,
}
