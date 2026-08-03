-- nvim-lspconfig - Quickstart configs for Nvim LSP
-- https://github.com/neovim/nvim-lspconfig
-- Includes mason for easy LSP installation, fidget for LSP progress, and lazydev for Lua development

return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    -- Mason: Automatically install LSPs and related tools
    {
      'mason-org/mason.nvim',
      cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
      build = ':MasonUpdate',
      opts = {},
    },
    {
      'mason-org/mason-lspconfig.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = { 'mason-org/mason.nvim' },
    },
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Fidget: Useful status updates for LSP
    { 'j-hui/fidget.nvim', opts = {} },

    -- Lazydev: Configures Lua LSP for Neovim config, runtime and plugins
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = 'luvit-meta/library', words = { 'vim%.uv' } },
        },
      },
    },
    { 'Bilal2453/luvit-meta' },

    -- TypeScript error translator
    {
      'dmmulroy/ts-error-translator.nvim',
      ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'vue' },
      config = function()
        require('ts-error-translator').setup()
      end,
    },
  },
  config = function()
    -- LSP stands for Language Server Protocol. It's a protocol that helps editors
    -- and language tooling communicate in a standardized fashion.
    --
    -- In general, you have a "server" which is some tool built to understand a particular
    -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
    -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
    -- processes that communicate with some "client" - in this case, Neovim!
    --
    -- LSP provides Neovim with features like:
    --  - Go to definition
    --  - Find references
    --  - Autocompletion
    --  - Symbol Search
    --  - and more!

    -- This function gets run when an LSP attaches to a particular buffer.
    -- That is to say, every time a new file is opened that is associated with
    -- an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
    -- function will be executed to configure the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- Create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- Find references for the word under your cursor.
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across files, etc.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- Get vue language server path for TypeScript integration
    local vue_language_server_path = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules/@vue/language-server'

    -- Enable the following language servers
    -- Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    -- Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    local servers = {
      clangd = {},
      -- gopls = {},

      -- Python with uv integration
      pyright = {
        before_init = function(_, config)
          -- Get the directory of the file being opened
          local root_dir = config.root_dir
          if root_dir then
            local handle = io.popen('cd "' .. root_dir .. '" && uv python find')
            if handle then
              local python_path = handle:read('*a'):gsub('%s+', '')
              handle:close()
              if python_path ~= '' then
                config.settings.python = config.settings.python or {}
                config.settings.python.pythonPath = python_path
              end
            end
          end
        end,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = 'basic',
            },
          },
        },
      },

      rust_analyzer = {},

      -- TypeScript/JavaScript with Vue support
      vtsls = {
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = '@vue/typescript-plugin',
                  location = vue_language_server_path,
                  languages = { 'vue' },
                  configNamespace = 'typescript',
                },
              },
            },
          },
        },
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
      },

      eslint = {},

      -- Lua with Neovim-specific settings
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = { disable = { 'missing-fields' } },
          },
        },
      },

      html = { filetypes = { 'html', 'twig', 'hbs' } },
      ruff = {},
      wgsl_analyzer = {},
      taplo = {
        root_markers = { '.taplo.toml', 'taplo.toml', '.git', '.jj' },
      },
      nushell = {},
      -- kotlin_lsp = {},
    }

    -- Detect platform
    local platform = require 'utils.platform'
    local linuxDistro = platform.getLinuxDistro()
    local has_nix = vim.fn.executable 'nix' == 1

    -- When nix is available (NixOS or Home Manager), all tools come from the nix wrapper —
    -- register servers directly and skip Mason entirely
    if has_nix then
      vim.lsp.config('nil_ls', {})
      vim.lsp.enable('nil_ls')
      vim.lsp.config('nixd', {})
      vim.lsp.enable('nixd')
      -- vim.lsp.config('statix', {})
      for server_name, server_config in pairs(servers) do
        vim.lsp.config(server_name, server_config)
        vim.lsp.enable(server_name)
      end
    else
      -- Use Mason to install and manage LSP servers
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      local ensure_installed = {}
      -- exclude lsps not currently provided by mason
      for name, _ in pairs(servers) do
        if name == 'nushell' then
          if vim.fn.executable 'nu' == 1 then
            vim.lsp.config('nushell', servers['nushell'])
          end
        else
          table.insert(ensure_installed, name)
        end
      end

      ---@type MasonLspconfigSettings
      ---@diagnostic disable-next-line: missing-fields
      require('mason-lspconfig').setup {
        automatic_enable = vim.tbl_keys(servers or {}),
      }

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Use modern Neovim 0.11+ vim.lsp.config() API
      for server_name, config in pairs(servers) do
        vim.lsp.config(server_name, config)
      end
    end
  end,
}
