return {
  'andymass/vim-matchup',
  event = 'VeryLazy',
  config = function()
    vim.g.matchup_matchparen_deferred = true
    vim.g.matchup_matchparen_hi_surround_always = true
  end,
}
