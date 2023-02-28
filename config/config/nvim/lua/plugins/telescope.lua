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
    map('c', '<c-r>', '<Plug>(TelescopeFuzzyCommandSearch)', { desc = '[Telescope] Command history picker' })
    map('n', '<leader>fb', ':Telescope buffers<CR>', { desc = '[Telescope] Open buffer picker' })
    map('n', '<leader>fc', ':Telescope commands<CR>', { desc = '[Telescope] Command picker' })
    map('n', '<leader>ff', ':Telescope find_files<CR>', { desc = '[Telescope] File picker' })
    map('n', '<leader>fg', ':Telescope live_grep_args<CR>', { desc = '[Telescope] Live grep' })
    map('n', '<leader>fk', ':Telescope keymaps<CR>', { desc = '[Telescope] Keymaps picker' })
    map(
      'n',
      '<leader>fl',
      ':Telescope current_buffer_fuzzy_find<CR>',
      { desc = '[Telescope] Current buffer line picker' }
    )
    map('n', '<leader>fo', ':Telescope oldfiles<CR>', { desc = '[Telescope] Recently edited files picker' })
    map('n', '<leader>fp', ':Telescope resume<CR>', { desc = '[Telescope] Resume last picker' })
    map('n', '<leader>ft', ':Telescope<CR>', { desc = '[Telescope] Default picker' })
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
