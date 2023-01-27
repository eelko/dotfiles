return {
  'ggandor/leap.nvim',
  dependencies = 'ggandor/leap-spooky.nvim',
  event = 'VeryLazy',
  config = function()
    require('leap').add_default_mappings()
    require('leap-spooky').setup {}
  end,
}
