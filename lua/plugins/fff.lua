-- fff.nvim - Freakin fast fuzzy file finder
-- https://github.com/dmtrKovalenko/fff.nvim

return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    require('fff.download').download_or_build_binary()
  end,
  opts = {},
  lazy = false,
  keys = {
    {
      '<leader>sf',
      function()
        require('fff').find_files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sg',
      function()
        require('fff').live_grep()
      end,
      desc = '[S]earch by [G]rep',
    },
    {
      '<leader>sw',
      function()
        require('fff').live_grep { query = vim.fn.expand '<cword>' }
      end,
      desc = '[S]earch current [W]ord',
    },
    {
      '<leader>sz',
      function()
        require('fff').live_grep {
          grep = {
            modes = { 'fuzzy', 'plain' },
          },
        }
      end,
      desc = '[S]earch fu[Z]zy grep',
    },
  },
}
