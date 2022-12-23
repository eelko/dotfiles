return {
  'christoomey/vim-tmux-navigator',
  keys = {
    { '<m-h>', ':TmuxNavigateLeft<CR>', silent = true },
    { '<m-j>', ':TmuxNavigateDown<CR>', silent = true },
    { '<m-k>', ':TmuxNavigateUp<CR>', silent = true },
    { '<m-l>', ':TmuxNavigateRight<CR>', silent = true },
  },
  config = function()
    vim.g.tmux_navigator_no_mappings = true
  end,
}
