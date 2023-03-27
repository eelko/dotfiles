return {
  'NvChad/nvim-colorizer.lua',
  cmd = 'ColorizerToggle',
  config = function()
    require('colorizer').setup {
      user_default_options = {
        css_fn = true,
        names = false,
        mode = 'virtualtext',
      },
    }
  end,
}
