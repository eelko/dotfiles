return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
  },
  init = function()
    local map = require('utils').map
    map('n', '<leader>fb', ':Telescope buffers<CR>')
    map('n', '<leader>fc', ':Telescope commands<CR>')
    map('n', '<leader>ff', ':Telescope find_files<CR>')
    map('n', '<leader>fg', ':Telescope live_grep_args<CR>')
    map('n', '<leader>fl', ':Telescope current_buffer_fuzzy_find<CR>')
    map('n', '<leader>fp', ':Telescope resume<CR>')
    map('n', '<leader>ft', ':Telescope<CR>')
  end,
  config = function()
    local actions = require 'telescope.actions'
    local lga_actions = require 'telescope-live-grep-args.actions'
    local telescope = require 'telescope'

    telescope.setup {
      defaults = {
        -- misc options
        file_ignore_patterns = { 'node_modules/', '.git/' },
        -- appearance
        entry_prefix = '  ',
        layout_config = {
          mirror = true,
          prompt_position = 'top',
          width = 0.5,
          height = 0.5,
        },
        layout_strategy = 'vertical',
        prompt_prefix = '     ',
        selection_caret = '  ',
        sorting_strategy = 'ascending',
        -- mappings
        mappings = {
          i = {
            ['<esc>'] = actions.close,
            ['<up>'] = actions.cycle_history_prev,
            ['<down>'] = actions.cycle_history_next,
            ['<left>'] = actions.preview_scrolling_down,
            ['<right>'] = actions.preview_scrolling_up,
            -- Allow readline mappings to work
            ['<C-d>'] = false,
            ['<C-e>'] = false,
            ['<C-u>'] = false,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
      extensions = {
        live_grep_args = {
          mappings = {
            i = {
              ['<C-k>'] = lga_actions.quote_prompt(),
            },
          },
        },
      },
    }

    telescope.load_extension 'fzf'
    telescope.load_extension 'live_grep_args'
  end,
}
