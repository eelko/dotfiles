return {
  'danymat/neogen',
  cmd = 'Neogen',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  version = '*', -- use latest stable version
  config = function()
    require('neogen').setup {}
  end,
}
