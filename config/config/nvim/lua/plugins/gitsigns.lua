local map = require('utils').map

return {
  'lewis6991/gitsigns.nvim',
  event = 'UIEnter',
  dependencies = 'nvim-lua/plenary.nvim',
  config = function()
    map('n', '<leader>gb', ':Gitsigns blame_line<CR>')

    require('gitsigns').setup {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▎' },
        topdelete = { text = '‾' },
        changedelete = { text = '▎' },
      },
      keymaps = {
        -- Default keymap options
        noremap = true,
        ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'" },
        ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'" },
        -- Text objects
        ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
        ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
      },
    }
  end,
}
