-- Tree-sitter grammar for ArkType
-- https://github.com/jeffrom/tree-sitter-arktype
-- Provides syntax highlighting for ArkType definitions in TypeScript

return {
  'nvim-treesitter/nvim-treesitter',
  opts = function(_, opts)
    -- Register arktype parser install info
    local parsers = require 'nvim-treesitter.parsers'
    parsers.arktype = {
      install_info = {
        url = 'https://github.com/jeffrom/tree-sitter-arktype',
        files = { 'src/parser.c' },
        branch = 'main',
      },
      filetype = 'typescript',
    }

    -- Ensure arktype is in the list of parsers to install
    opts.ensure_installed = opts.ensure_installed or {}
    if type(opts.ensure_installed) == 'table' then
      vim.list_extend(opts.ensure_installed, { 'arktype' })
    end

    -- Enable injections for typescript/tsx files
    vim.treesitter.language.register('arktype', 'typescript')
    vim.treesitter.language.register('arktype', 'typescriptreact')

    return opts
  end,
}
