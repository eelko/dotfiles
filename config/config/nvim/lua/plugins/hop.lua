return {
  'phaazon/hop.nvim',
  branch = 'v2',
  keys = {
    { 's', ':HopChar2<CR>', desc = '[Hop] Go to any bigram in the current buffer', silent = true },
    { 'gs', ':HopChar2MW<CR>', desc = '[Hop] Go to any bigram in any visible buffer', silent = true },
  },
  config = function()
    require('hop').setup {}
  end,
}
