return {
  'kylechui/nvim-surround',
  keys = {
    'cs',
    'ds',
    'ys',
    { 'S', mode = 'v' },
  },
  version = '*', -- use latest stable version
  config = function()
    require('nvim-surround').setup {
      keymaps = {
        insert = false,
        insert_line = false,
      },
    }
  end,
}
