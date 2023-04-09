-- Misc
vim.opt.autoread = false -- Don't auto reload files from disk when they change outisde Vim
vim.opt.clipboard:prepend { 'unnamedplus' } -- Use system clipboard for all operations
vim.opt.diffopt:prepend { 'linematch:60' } -- Better diffs
vim.opt.hidden = true -- Allows buffers to be left unsaved (bp/bn)
vim.opt.inccommand = 'split' -- Show partial off-screen substitution results in a preview window
vim.opt.jumpoptions:prepend { 'view' } -- Restore viewport on jump
vim.opt.mouse = 'a' -- Enable mouse
vim.opt.mousemodel = 'extend' -- Right mouse button extends a selection (or: disable the annoying popup menu)
vim.opt.showmode = false -- Don't show edit mode in command bar
vim.opt.updatetime = 300 -- Shorter time to trigger CursorHold autocmd

-- Appearance
vim.opt.cursorline = true -- Highlight current line
vim.opt.laststatus = 3 -- Enable global statusline
vim.opt.list = true -- Show unprintable characters
vim.opt.listchars = 'tab:».,trail:⌴,extends:…,precedes:…,nbsp:°' -- Unprintable characters
vim.opt.number = true -- Display line numbers
vim.opt.pumheight = 8 -- Limit completion menu height
vim.opt.relativenumber = true -- Use relative numbers
vim.opt.signcolumn = 'yes' -- ALways show the sign column
vim.opt.termguicolors = true -- Enables RGB color in the terminal

-- Formatting
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Number of spaces used for indentation
vim.opt.softtabstop = 2 -- Makes <BS> (backspace key) treat two spaces like a tab
vim.opt.tabstop = 2 -- Number of spaces for each <Tab>
vim.opt.wrap = false -- Disable line wrapping

-- Searching
vim.opt.ignorecase = true -- Ignore case sensitivity
vim.opt.smartcase = true -- Enable case-smart searching (overrides ignorecase)
