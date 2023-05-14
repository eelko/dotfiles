return {
  'phaazon/hop.nvim',
  enabled = false,
  branch = 'v2',
  keys = {
    {
      's',
      '<cmd>HopChar2<CR>',
      mode = { 'n', 'v' },
      desc = '[Hop] Go to any bigram in the current buffer',
      silent = true,
    },
    { 'gs', '<cmd>HopChar2MW<CR>', desc = '[Hop] Go to any bigram in any visible buffer', silent = true },
  },
  config = function()
    require('hop').setup {}
  end,
}
