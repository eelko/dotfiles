return {
  'catppuccin/nvim',
  name = 'catppuccin',
  event = 'VimEnter',
  config = function()
    vim.cmd.colorscheme 'catppuccin-macchiato'
  end,
}
