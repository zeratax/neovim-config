-- Configures Lua LSP for your Neovim config, runtime and plugins
-- Used for completion, annotations and signatures of Neovim APIs
return {
  'folke/lazydev.nvim',
  ft = 'lua',
  dependencies = {
    'Bilal2453/luvit-meta',
  },
  opts = {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = 'luvit-meta/library', words = { 'vim%.uv' } },
    },
  },
}
