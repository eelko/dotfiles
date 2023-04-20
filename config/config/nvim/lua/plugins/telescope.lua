return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
  },
  cmd = 'Telescope',
  keys = {
    {
      '<c-r>',
      '<Plug>(TelescopeFuzzyCommandSearch)',
      desc = '[Telescope] Command history picker',
      mode = 'c',
      silent = true,
    },
    { '<leader>fb', ':Telescope buffers<CR>', desc = '[Telescope] Open buffer picker', silent = true },
    { '<leader>fc', ':Telescope commands<CR>', desc = '[Telescope] Command picker', silent = true },
    { '<leader>ff', ':Telescope find_files<CR>', desc = '[Telescope] File picker', silent = true },
    { '<leader>fg', ':Telescope live_grep_args<CR>', desc = '[Telescope] Live grep', silent = true },
    { '<leader>fk', ':Telescope keymaps<CR>', desc = '[Telescope] Keymaps picker', silent = true },
    {
      '<leader>fl',
      ':Telescope current_buffer_fuzzy_find<CR>',
      desc = '[Telescope] Current buffer line picker',
      silent = true,
    },
    { '<leader>fo', ':Telescope oldfiles<CR>', desc = '[Telescope] Recently edited files picker', silent = true },
    { '<leader>fp', ':Telescope<CR>', desc = '[Telescope] Default picker', silent = true },
    { '<leader>fr', ':Telescope resume<CR>', desc = '[Telescope] Resume last picker', silent = true },
    {
      '<leader>ft',
      ':Telescope tests_picker current_buffer_tests layout_config={width=0.9,height=0.9}<CR>',
      desc = '[Telescope] Jump to a test in current buffer',
      silent = true,
    },
  },
  config = function()
    local actions = require 'telescope.actions'
    local lga_actions = require 'telescope-live-grep-args.actions'
    local telescope = require 'telescope'
    local flash = require('utils').flash

    -- Custom select action that centers and flashes the current line
    local function custom_select(prompt_bufnr)
      actions.select_default(prompt_bufnr)
      actions.center(prompt_bufnr)
      local row = vim.api.nvim_win_get_cursor(0)[1]
      flash(row - 1, row - 1)
    end

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
            ['<cr>'] = custom_select,
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
    telescope.load_extension 'tests_picker'
    telescope.load_extension 'live_grep_args'
  end,
}
