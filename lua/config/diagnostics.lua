local M = {}

M.diagnostic_state = {
  virtual_text = true,
  virtual_lines = false,
}

function M.toggle_diagnostic_display()
  M.diagnostic_state.virtual_text = not M.diagnostic_state.virtual_text
  M.diagnostic_state.virtual_lines = not M.diagnostic_state.virtual_lines

  vim.diagnostic.config {
    virtual_text = M.diagnostic_state.virtual_text,
    underline = true,
    virtual_lines = M.diagnostic_state.virtual_lines,
    float = {
      source = true,
    },
    signs = true,
  }

  local mode = M.diagnostic_state.virtual_text and 'virtual text' or 'virtual lines'
  vim.notify('Diagnostic display: ' .. mode, vim.log.levels.INFO)
end

function M.setup(opts)
  opts = opts or {}

  local toggle_keybind = opts.toggle_keymap or '<Leader>td'
  local quickfix_keybind = opts.quickfix_keymap or '<Leader>q'
  local floating_keybind = opts.floating_keymap or '<Leader>e'

  vim.keymap.set('n', toggle_keybind, M.toggle_diagnostic_display, {
    desc = 'Toggle diagnostic display style',
    silent = true,
  })
  vim.keymap.set('n', quickfix_keybind, vim.diagnostic.setloclist, {
    desc = 'Open diagnostic [Q]uickfix list',
  })
  vim.keymap.set('n', floating_keybind, vim.diagnostic.open_float, {
    desc = 'Show diagnostic [E]rror messages',
  })

  vim.diagnostic.config {
    virtual_text = M.diagnostic_state.virtual_text,
    underline = true,
    virtual_lines = M.diagnostic_state.virtual_lines,
    float = {
      source = true,
    },
    signs = true,
  }
end

return M
