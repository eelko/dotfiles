return {
  'linty-org/readline.nvim',
  event = { 'CmdlineEnter', 'CmdWinEnter', 'InsertEnter' },
  config = function()
    local map = require('utils').map
    local r = require 'readline'

    map('!', '<C-k>', r.kill_line, { desc = '[Readline] Kill from cursor position until end of line' })
    map('!', '<C-u>', r.backward_kill_line, { desc = '[Readline] Kill from cursor position until beginning of line' })
    map('!', '<M-d>', r.kill_word, { desc = '[Readline] Kill from cursor position until end of word' })
    map('!', '<C-w>', r.backward_kill_word, { desc = '[Readline] Kill from cursor position until beginning of word' })
    map('!', '<C-a>', r.beginning_of_line, { desc = '[Readline] Jump to beginning of line' })
    map('!', '<C-e>', r.end_of_line, { desc = '[Readline] Jump to end of line' })
    map('!', '<M-b>', r.backward_word, { desc = '[Readline] Jump to the beginning of previous word' })
    map('!', '<M-f>', r.forward_word, { desc = '[Readline] Jump to the beginning of next word' })

    -- `map` does not work for the mappings below
    -- apparently the `silent` option breaks them
    vim.keymap.set('!', '<C-b>', '<Left>', { desc = '[Readline] Move cursor to the left' })
    vim.keymap.set('!', '<C-f>', '<Right>', { desc = '[Readline] Move cursor to the right' })
    vim.keymap.set('!', '<C-d>', '<Delete>', { desc = '[Readline] Delete one character forward' })
    vim.keymap.set('!', '<C-h>', '<BS>', { desc = '[Readline] Delete one character backward' })
  end,
}
