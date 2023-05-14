return {
  'lukas-reineke/indent-blankline.nvim',
  enabled = false,
  event = 'BufReadPost', -- cannot be UIEnter or `show_first_indent_level=false` won't work until cursor moves
  config = function()
    require('indent_blankline').setup {
      show_current_context = true,
      show_first_indent_level = false,
      show_trailing_blankline_indent = false,
    }
  end,
}
