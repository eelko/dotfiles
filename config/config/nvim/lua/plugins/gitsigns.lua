return {
  'lewis6991/gitsigns.nvim',
  enabled = false,
  event = 'UIEnter',
  dependencies = 'nvim-lua/plenary.nvim',
  config = function()
    local map = require('utils').map
    map('n', '<leader>gb', ':Gitsigns blame_line<CR>', { desc = '[Git Signs] Show Git Blame for current line' })

    require('gitsigns').setup {
      signs = {
        add = { text = '▐' },
        change = { text = '▐' },
        delete = { text = '▐' },
        topdelete = { text = '▔' },
        changedelete = { text = '▐' },
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
