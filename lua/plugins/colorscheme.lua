-- Hypersubatomic colorscheme
return {
  'tritlo/hypersubatomic.vim',
  priority = 1000, -- Load before all other plugins
  init = function()
    vim.opt.termguicolors = true
    vim.g.hypersubatomic_terminal_italics = 1
    vim.cmd.colorscheme 'hypersubatomic'
  end,
}
