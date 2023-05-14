local function notify(cmd)
  return string.format("<cmd>call VSCodeNotify('%s')<CR>", cmd)
end

local function v_notify(cmd)
  return string.format("<cmd>call VSCodeNotifyVisual('%s', 1)<CR>", cmd)
end

-- Options
vim.g.mapleader = ' '
vim.opt.clipboard:prepend { 'unnamedplus' } -- Use system clipboard for all operations
vim.opt.ignorecase = true -- Ignore case sensitivity
vim.opt.smartcase = true -- Enable case-smart searching (overrides ignorecase)

-- Keymaps
local keymap = vim.keymap.set

--- Neovim keymaps
keymap('n', '<esc>', ':nohlsearch<cr>', { desc = 'Clear highlighted search matches' })
keymap('x', 'p', 'pgvy', { desc = 'Paste in visual mode without yanking' })

--- VS Code keymaps
keymap('n', '<Leader>w', notify 'workbench.action.files.save')
keymap('n', '<Leader>x', notify 'workbench.action.closeActiveEditor')
keymap('n', '[q', notify 'search.action.focusPreviousSearchResult')
keymap('n', '\\', notify 'workbench.action.toggleSidebarVisibility')
keymap('n', ']q', notify 'search.action.focusNextSearchResult')
keymap('n', 'gn', notify 'workbench.action.nextEditor')
keymap('n', 'gp', notify 'workbench.action.previousEditor')

--- VS Code: Pikers keymaps
keymap('n', '<Leader>fc', notify 'workbench.action.showCommands') -- command picker
keymap('n', '<Leader>ff', notify 'workbench.action.quickOpen') -- file picker
keymap('n', '<Leader>fg', notify 'workbench.action.findInFiles') -- live grep
keymap('v', '<Leader>fc', v_notify 'workbench.action.showCommands') -- command picker

--- VS Code: LSP keymaps
keymap('n', 'gr', notify 'editor.action.goToReferences')
keymap('n', 'td', notify 'editor.action.goToTypeDefinition')
keymap('n', '<Leader>r', notify 'editor.action.rename')
keymap('n', '<Leader>ca', notify 'editor.action.refactor') -- code actions
keymap('v', '<Leader>ca', v_notify 'editor.action.refactor') -- cocode actions
keymap('v', '<Leader>s', v_notify 'workbench.action.showAllSymbols')

--- VS Code: Diagnostics keymaps
keymap('n', ']d', notify 'editor.action.marker.nextInFiles')
keymap('n', '[d', notify 'editor.action.marker.prevtInFiles')
keymap('n', '<Leader>d', notify 'workbench.actions.view.problems')

-- Autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text (requires NeoVim 0.6+)',
  callback = function()
    vim.highlight.on_yank { higroup = 'Visual', timeout = 200 }
  end,
})

-- Plugins
vim.opt.runtimepath:prepend(vim.fn.stdpath 'data' .. '/lazy/lazy.nvim')

require('lazy').setup {
  require 'plugins.commentary',
  require 'plugins.surround',
}

return {}
