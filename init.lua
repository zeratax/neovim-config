-- [[ Neovim Configuration ]]
-- Modular configuration structure inspired by kickstart.nvim
-- Each plugin lives in its own file under lua/plugins/

-- Load core configuration
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

-- Bootstrap and configure lazy.nvim plugin manager
-- This will automatically load all plugins from lua/plugins/
require 'config.lazy'

-- Load custom utilities and configurations
require('config.diagnostics').setup()
require 'utils.treesitter_sort'
