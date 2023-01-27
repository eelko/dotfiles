return {
  'ggandor/leap.nvim',
  dependencies = 'ggandor/leap-spooky.nvim',
  event = 'VeryLazy',
  config = function()
    require('leap').add_default_mappings()
    vim.keymap.del({ 'x', 'o' }, 'x')
    vim.keymap.del({ 'x', 'o' }, 'X')

    require('leap-spooky').setup {}
  end,
}
