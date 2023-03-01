local map = require('utils').map

-- Space as leader
vim.g.mapleader = ' '

-- Command mode
map('c', '<c-g>', "<c-r>=expand('%:h').'/'<cr>", { desc = 'Expand current file path', silent = false })
map('c', '<cn>', '<down>', { desc = 'Go to next entry in command history' })
map('c', '<cp>', '<up>', { desc = 'Go to previous entry in command history' })

-- Normal mode
map('n', 'gn', ':if &buftype == "" | bnext | endif<CR>', { desc = 'Go to next buffer' })
map('n', 'gp', ':if &buftype == "" | bprevious | endif<CR>', { desc = 'Go to previous buffer' })
map('n', '<c-w>tc', ':tabclose<cr>', { desc = 'Close current tab' })
map('n', '<c-w>tn', ':tabnew %<cr>', { desc = 'Create new tab' })
map('n', '<esc>', ':nohlsearch<cr>', { desc = 'Clear highlighted search matches' })
map(
  'n',
  '<leader>D',
  "(bufnr('%') == getbufinfo({'buflisted': 1})[-1].bufnr ? ':bp' : ':bn').'<bar>bd! #<CR>'",
  { desc = 'Cleverly close current buffer ignoring unsaved changes (based on reddit.com/em9qvv)', expr = true }
)
map(
  'n',
  '<leader>d',
  "(bufnr('%') == getbufinfo({'buflisted': 1})[-1].bufnr ? ':bp' : ':bn').'<bar>bd #<CR>'",
  { desc = 'Cleverly close current buffer (based on reddit.com/em9qvv)', expr = true }
)
map('n', '<leader>Q', ':qall!<cr>', { desc = 'Quit editor ignoring unsaved buffers' })
map('n', '<leader>q', ':qall<cr>', { desc = 'Quit editor' })
map('n', '<leader>w', ':write<cr>', { desc = 'Save current buffer' })
map('n', '<leader>x', ':xit<cr>', { desc = 'Save current buffer and quit editor' })
map('n', '[Q', ':cfirst<CR>', { desc = 'Go to first quickfix entry' })
map('n', '[q', ':cprevious<CR>', { desc = 'Go to previous quickfix entry' })
map('n', ']Q', ':clast<CR>', { desc = 'Go to last quickfix entry' })
map('n', ']q', ':cnext<CR>', { desc = 'Go to next quickfix entry' })
map('n', 'gy', '`[v`]', { desc = 'Visual select last yank/paste' })
map('n', 'j', 'gj', { desc = 'Navigate down wrapped lines' })
map('n', 'k', 'gk', { desc = 'Navigate up wrapped lines' })

-- Visual mode
map('x', 'p', 'pgvy', { desc = 'Paste in visual mode without yanking' })
