-- bootstrap package manager
local lazy_path = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazy_path) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazy_path,
  }
end

vim.opt.runtimepath:prepend(lazy_path)

-- load plugins
require('lazy').setup('plugins', {
  defaults = {
    lazy = true,
  },
  checker = {
    enabled = true,
    notify = false,
    frequency = 86400, -- check for updates once a day
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  install = {
    colorscheme = { 'tokyonight', 'habamax' },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        '2html_plugin',
        'getscript',
        'getscriptPlugin',
        'gzip',
        'logipat',
        'netrw',
        'netrwFileHandlers',
        'netrwPlugin',
        'netrwSettings',
        'rrhelper',
        'spellfile_plugin',
        'tar',
        'tarPlugin',
        'tohtml',
        'tutor',
        'vimball',
        'vimballPlugin',
        'zip',
        'zipPlugin',
      },
    },
  },
})
