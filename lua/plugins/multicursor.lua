-- Multicursor.nvim - Multiple cursors plugin
-- https://github.com/jake-stewart/multicursor.nvim

return {
  'jake-stewart/multicursor.nvim',
  branch = '1.0',
  event = 'VimEnter',
  config = function()
    local mc = require 'multicursor-nvim'
    mc.setup()

    -- Add or skip cursor above/below the main cursor
    vim.keymap.set({ 'n', 'x' }, '<up>', function()
      mc.lineAddCursor(-1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<down>', function()
      mc.lineAddCursor(1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<leader><up>', function()
      mc.lineSkipCursor(-1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<leader><down>', function()
      mc.lineSkipCursor(1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<C-k>', function()
      mc.lineAddCursor(-1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<C-j>', function()
      mc.lineAddCursor(1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<M-k>', function()
      mc.lineSkipCursor(-1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<M-j>', function()
      mc.lineSkipCursor(1)
    end)

    -- Match cursors
    vim.keymap.set({ 'n', 'x' }, '<leader>n', function()
      mc.matchAddCursor(1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<leader>m', function()
      mc.matchSkipCursor(1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<leader>N', function()
      mc.matchAddCursor(-1)
    end)
    vim.keymap.set({ 'n', 'x' }, '<leader>M', function()
      mc.matchSkipCursor(-1)
    end)

    -- Operator to match word under cursor
    vim.keymap.set({ 'n', 'x' }, 'mw', function()
      mc.operator { motion = 'iw', visual = true }
    end)
    vim.keymap.set('n', 'mW', mc.operator)

    -- Add all matches in the document
    vim.keymap.set({ 'n', 'x' }, '<leader>A', mc.matchAllAddCursors)

    -- Rotate the main cursor
    vim.keymap.set({ 'n', 'x' }, '<left>', mc.nextCursor)
    vim.keymap.set({ 'n', 'x' }, '<right>', mc.prevCursor)
    vim.keymap.set({ 'n', 'x' }, '<C-l>', mc.nextCursor)
    vim.keymap.set({ 'n', 'x' }, '<C-h>', mc.prevCursor)

    -- Delete the main cursor
    vim.keymap.set({ 'n', 'x' }, '<leader>x', mc.deleteCursor)

    -- Add and remove cursors with control + left click
    vim.keymap.set('n', '<c-leftmouse>', mc.handleMouse)
    vim.keymap.set('n', '<c-leftdrag>', mc.handleMouseDrag)

    -- Easy way to add and remove cursors using the main cursor
    vim.keymap.set({ 'n', 'x' }, '<c-q>', mc.toggleCursor)

    -- Clone every cursor and disable the originals
    vim.keymap.set({ 'n', 'x' }, '<leader><c-q>', mc.duplicateCursors)

    -- Escape handler for multicursor
    vim.keymap.set('n', '<esc>', function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      else
        -- Default <esc> handler
      end
    end)

    -- Bring back cursors if you accidentally clear them
    vim.keymap.set('n', '<leader>gv', mc.restoreCursors)

    -- Align cursor columns
    vim.keymap.set('n', '<leader>a', mc.alignCursors)

    -- Split visual selections by regex
    vim.keymap.set('x', 'S', mc.splitCursors)

    -- Append/insert for each line of visual selections
    vim.keymap.set('x', 'I', mc.insertVisual)
    vim.keymap.set('x', 'A', mc.appendVisual)

    -- Match new cursors within visual selections by regex
    vim.keymap.set('x', 'M', mc.matchCursors)

    -- Rotate visual selection contents
    vim.keymap.set('x', '<leader>t', function()
      mc.transposeCursors(1)
    end)
    vim.keymap.set('x', '<leader>T', function()
      mc.transposeCursors(-1)
    end)

    -- Jumplist support
    vim.keymap.set({ 'x', 'n' }, '<c-i>', mc.jumpForward)
    vim.keymap.set({ 'x', 'n' }, '<c-o>', mc.jumpBackward)

    -- Customize how cursors look
    vim.api.nvim_set_hl(0, 'MultiCursorCursor', { link = 'Cursor' })
    vim.api.nvim_set_hl(0, 'MultiCursorVisual', { link = 'Visual' })
    vim.api.nvim_set_hl(0, 'MultiCursorSign', { link = 'SignColumn' })
    vim.api.nvim_set_hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
    vim.api.nvim_set_hl(0, 'MultiCursorDisabledCursor', { link = 'Visual' })
    vim.api.nvim_set_hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
    vim.api.nvim_set_hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
  end,
}
