local map = require('utils').map

return {
  'linty-org/readline.nvim',
  event = { 'CmdlineEnter', 'CmdWinEnter', 'InsertEnter' },
  config = function()
    local readline = require 'readline'

    map('!', '<C-k>', readline.kill_line)
    map('!', '<C-u>', readline.backward_kill_line)
    map('!', '<M-d>', readline.kill_word)
    map('!', '<C-w>', readline.backward_kill_word)
    map('!', '<C-a>', readline.beginning_of_line)
    map('!', '<C-e>', readline.end_of_line)
    map('!', '<M-b>', readline.backward_word)
    map('!', '<M-f>', readline.forward_word)

    -- `map` does not work for the mappings below
    -- apparently the `silent` option breaks them
    vim.keymap.set('!', '<C-b>', '<Left>')
    vim.keymap.set('!', '<C-f>', '<Right>')
    vim.keymap.set('!', '<C-d>', '<Delete>')
    vim.keymap.set('!', '<C-h>', '<BS>')
  end,
}
