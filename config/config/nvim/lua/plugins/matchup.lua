return {
  'andymass/vim-matchup',
  enabled = false,
  event = 'BufReadPost',
  config = function()
    vim.g.matchup_matchparen_deferred = true
    vim.g.matchup_matchparen_hi_surround_always = true
  end,
}
