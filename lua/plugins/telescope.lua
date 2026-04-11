-- telescope.nvim - Fuzzy finder for files, LSP, grep, etc.
-- https://github.com/nvim-telescope/telescope.nvim

return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  branch = 'master',
  keys = {
    { '<leader>sh', '<cmd>Telescope help_tags<cr>', desc = '[S]earch [H]elp' },
    { '<leader>sk', '<cmd>Telescope keymaps<cr>', desc = '[S]earch [K]eymaps' },
    { '<leader>sf', '<cmd>Telescope find_files<cr>', desc = '[S]earch [F]iles' },
    { '<leader>ss', '<cmd>Telescope builtin<cr>', desc = '[S]earch [S]elect Telescope' },
    { '<leader>sw', '<cmd>Telescope grep_string<cr>', desc = '[S]earch current [W]ord' },
    { '<leader>sg', '<cmd>Telescope live_grep<cr>', desc = '[S]earch by [G]rep' },
    { '<leader>sd', '<cmd>Telescope diagnostics<cr>', desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', '<cmd>Telescope resume<cr>', desc = '[S]earch [R]esume' },
    { '<leader>s.', '<cmd>Telescope oldfiles<cr>', desc = '[S]earch Recent Files' },
    { '<leader><leader>', '<cmd>Telescope buffers<cr>', desc = '[ ] Find existing buffers' },
    { '<leader>u', '<cmd>Telescope undo<cr>', desc = '[U]ndo Tree' },
    {
      '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader>s/',
      function()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      desc = '[S]earch [/] in Open Files',
    },
    {
      '<leader>sn',
      function()
        require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = '[S]earch [N]eovim files',
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    {
      'debugloop/telescope-undo.nvim',
    },
    {
      -- Harpoon integration
      'ThePrimeagen/harpoon',
      opts = {
        menu = {
          width = vim.api.nvim_win_get_width(0) - 8,
        },
      },
      keys = {
        {
          '<leader>ha',
          function()
            require('harpoon.mark').add_file()
          end,
          desc = '[H]arpoon [A]dd current file',
        },
        {
          '<leader>hm',
          function()
            require('harpoon.ui').toggle_quick_menu()
          end,
          desc = '[H]arpoon toggle Quick[M]enu',
        },
        { '<leader>ht', '<cmd>Telescope harpoon marks<cr>', desc = '[H]arpoon [T]elescope marks' },
        {
          '<leader>h1',
          function()
            require('harpoon.ui').nav_file(1)
          end,
          desc = '[H]arpoon navigate to file [1]',
        },
        {
          '<leader>h2',
          function()
            require('harpoon.ui').nav_file(2)
          end,
          desc = '[H]arpoon navigate to file [2]',
        },
        {
          '<leader>h3',
          function()
            require('harpoon.ui').nav_file(3)
          end,
          desc = '[H]arpoon navigate to file [3]',
        },
        {
          '<leader>h4',
          function()
            require('harpoon.ui').nav_file(4)
          end,
          desc = '[H]arpoon navigate to file [4]',
        },
        {
          '<leader>h5',
          function()
            require('harpoon.ui').nav_file(5)
          end,
          desc = '[H]arpoon navigate to file [5]',
        },
        {
          '<leader>h6',
          function()
            require('harpoon.ui').nav_file(6)
          end,
          desc = '[H]arpoon navigate to file [6]',
        },
        {
          '<leader>h7',
          function()
            require('harpoon.ui').nav_file(7)
          end,
          desc = '[H]arpoon navigate to file [7]',
        },
        {
          '<leader>h8',
          function()
            require('harpoon.ui').nav_file(8)
          end,
          desc = '[H]arpoon navigate to file [8]',
        },
        {
          '<leader>h9',
          function()
            require('harpoon.ui').nav_file(9)
          end,
          desc = '[H]arpoon navigate to file [9]',
        },
        {
          '<leader>h0',
          function()
            require('harpoon.ui').nav_file(10)
          end,
          desc = '[H]arpoon navigate to file [0]',
        },
      },
    },
  },
  config = function()
    require('telescope').setup {
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--trim',
          '--no-require-git',
          '--hidden',
          '--glob=!.git/',
          '--glob=!.jj/',
          '--glob=!bun.lock',
        },
      },
      pickers = {
        find_files = {
          find_command = {
            'fd',
            '--type',
            'f',
            '--hidden',
            '--strip-cwd-prefix',
            '--no-require-git',
            '--exclude',
            '.git',
            '--exclude',
            '.jj',
          },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
        undo = {
          use_delta = false,
          layout_strategy = 'horizontal',
          layout_config = {
            preview_width = 0.6,
          },
        },
      },
    }

    -- Load telescope extensions
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
    pcall(require('telescope').load_extension, 'undo')
    pcall(require('telescope').load_extension, 'harpoon')
  end,
}
