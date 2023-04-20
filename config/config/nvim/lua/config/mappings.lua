local map = require('utils').map

-- Space as leader
vim.g.mapleader = ' '

-- Command mode
map('c', '<c-g>', "<c-r>=expand('%:h').'/'<cr>", { desc = 'Expand current file path', silent = false })
map('c', '<cn>', '<down>', { desc = 'Go to next entry in command history' })
map('c', '<cp>', '<up>', { desc = 'Go to previous entry in command history' })

-- Insert mode
vim.keymap.set('i', '<C-c>', function()
  local cursor_position = vim.fn.getcurpos()
  local search_count = vim.fn.searchcount({ recompute = 1 }).total

  for _ = 1, search_count do
    vim.cmd 'normal! .'
  end

  vim.fn.setpos('.', cursor_position)
  vim.cmd 'stopinsert'
end, { desc = 'Repeat last change made with `cgn` for all remaining occurrences' })

-- Normal mode
map('n', '<c-w>tc', ':tabclose<cr>', { desc = 'Close current tab' })
map('n', '<c-w>tn', ':tabnew %<cr>', { desc = 'Create new tab' })
map('n', '<esc>', ':nohlsearch<cr>', { desc = 'Clear highlighted search matches' })
map('n', '<leader>Q', ':qall!<cr>', { desc = 'Quit editor ignoring unsaved buffers' })
map('n', '<leader>q', ':qall<cr>', { desc = 'Quit editor' })
map('n', '<leader>w', ':write<cr>', { desc = 'Save current buffer' })
map('n', '[Q', ':cfirst<CR>', { desc = 'Go to first quickfix entry' })
map('n', '[q', ':cprevious<CR>', { desc = 'Go to previous quickfix entry' })
map('n', ']Q', ':clast<CR>', { desc = 'Go to last quickfix entry' })
map('n', ']q', ':cnext<CR>', { desc = 'Go to next quickfix entry' })
map('n', 'gy', '`[v`]', { desc = 'Visual select last yank/paste' })
map('n', 'j', 'gj', { desc = 'Navigate down wrapped lines' })
map('n', 'k', 'gk', { desc = 'Navigate up wrapped lines' })

map('n', '<leader>x', require('utils').clever_close, { desc = 'Save and close current buffer' })

map('n', 'gn', function()
  require('utils').switch_buffer 'next'
end, { desc = 'Go to next buffer' })

map('n', 'gp', function()
  require('utils').switch_buffer 'previous'
end, { desc = 'Go to previous buffer' })

-- Visual mode
map('x', 'p', 'pgvy', { desc = 'Paste in visual mode without yanking' })
