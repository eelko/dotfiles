require 'utils'
local telescope = require 'telescope'
local actions = require 'telescope.actions'

telescope.setup {
  defaults = {
    -- misc options
    file_ignore_patterns = { 'node_modules/', '.git/' },
    -- appearance
    borderchars = { '' },
    entry_prefix = '  ',
    layout_config = { mirror = true, prompt_position = 'top' },
    layout_strategy = 'vertical',
    prompt_prefix = '     ',
    selection_caret = '  ',
    sorting_strategy = 'ascending',
    -- mappings
    mappings = {
      i = {
        ['<esc>'] = actions.close,
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true,
      layout_strategy = 'flex',
      layout_config = {
        horizontal = {
          prompt_position = 'top',
          preview_width = 0.55,
        },
        mirror = false,
      },
    },
    live_grep = {
      on_input_filter_cb = function(prompt)
        return { prompt = prompt:gsub('%s', '.*') }
      end,
    },
  },
}

telescope.load_extension 'fzf'

-- Appearance
-- Colors from https://github.com/thanhvule0310/dotfiles/blob/main/nvim/lua/theme.lua
local colors = {
  bg = '#2e3440',
  fg = '#ECEFF4',
  red = '#bf616a',
  orange = '#d08770',
  yellow = '#ebcb8b',
  blue = '#5e81ac',
  green = '#a3be8c',
  cyan = '#88c0d0',
  magenta = '#b48ead',
  pink = '#FFA19F',
  grey1 = '#f8fafc',
  grey2 = '#f0f1f4',
  grey3 = '#eaecf0',
  grey4 = '#d9dce3',
  grey5 = '#c4c9d4',
  grey6 = '#b5bcc9',
  grey7 = '#929cb0',
  grey8 = '#8e99ae',
  grey9 = '#74819a',
  grey10 = '#616d85',
  grey11 = '#464f62',
  grey12 = '#3a4150',
  grey13 = '#333a47',
  grey14 = '#242932',
  grey15 = '#1e222a',
  grey16 = '#1c1f26',
  grey17 = '#0f1115',
  grey18 = '#0d0e11',
  grey19 = '#020203',
}

highlight('TelescopePromptNormal', { bg = colors.grey13 })
highlight('TelescopeResultsNormal', { bg = colors.grey15 })
highlight('TelescopePreviewNormal', { bg = colors.grey16 })

highlight('TelescopePromptBorder', { bg = colors.grey13, fg = colors.grey13 })
highlight('TelescopeResultsBorder', { bg = colors.grey15, fg = colors.grey15 })
highlight('TelescopePreviewBorder', { bg = colors.grey16, fg = colors.grey16 })

highlight('TelescopePromptTitle', { fg = colors.grey13 })
highlight('TelescopeResultsTitle', { fg = colors.grey15 })
highlight('TelescopePreviewTitle', { fg = colors.grey16 })

-- Integration with vim-action-mapper
vim.cmd [[
  function! GrepWithMotion(text, type)
  execute('lua require("telescope.builtin").grep_string({search = "'.trim(a:text).'"})')
  endfunction
]]
