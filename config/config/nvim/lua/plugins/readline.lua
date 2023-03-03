return {
  'linty-org/readline.nvim',
  event = { 'CmdlineEnter', 'CmdWinEnter', 'InsertEnter' },
  config = function()
    local map = require('utils').map
    local readline = require 'readline'

    map('c', '<C-k>', readline.kill_line)
    map('c', '<C-u>', readline.backward_kill_line)
    map('c', '<M-d>', readline.kill_word)
    map('c', '<C-w>', readline.backward_kill_word)
    map('c', '<C-a>', readline.beginning_of_line)
    map('c', '<C-e>', readline.end_of_line)
    map('c', '<M-b>', readline.backward_word)
    map('c', '<M-f>', readline.forward_word)

    -- `map` does not work for the mappings below
    -- apparently the `silent` option breaks them
    vim.keymap.set('c', '<C-b>', '<Left>')
    vim.keymap.set('c', '<C-f>', '<Right>')
    vim.keymap.set('c', '<C-d>', '<Delete>')
    vim.keymap.set('c', '<C-h>', '<BS>')
  end,
}
