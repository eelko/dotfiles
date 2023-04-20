local logger = require 'telescope.tests_picker.logger'

-- Telescope moduels
local telescope = require 'telescope'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local config = require('telescope.config').values
local entry_display = require 'telescope.pickers.entry_display'

-- Icons module
local devicons = require 'nvim-web-devicons'

local M = {}

local function read_test_titles_from(filepath)
  local file = io.open(filepath, 'r')

  if not file then
    logger.error('Error opening file "' .. filepath .. '".')
    return {}
  end

  local test_titles = require('telescope.tests_picker.parser').parse_tests(file)
  file:close()

  return test_titles
end

function M.current_buffer_tests(opts)
  opts = opts or {}

  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { width = 3 }, -- Line number width
      { remaining = true }, -- Test description width
    },
  }

  local function make_display(entry)
    return displayer {
      { tostring(entry.lnum), 'LineNr' },
      { entry.value, 'CursorLineNr' },
    }
  end

  local function get_indent_markers(entry)
    local markers = {}

    for i = 0, entry.nesting_level - 1 do
      if (entry.is_last_at_level and i == entry.nesting_level - 1) or entry.is_final_entry then
        table.insert(markers, '└ ')
      else
        table.insert(markers, '│ ')
      end
    end

    return table.concat(markers)
  end

  local function get_icon(entry, filepath)
    if entry.block_type == 'describe' then
      return ' '
    elseif entry.block_type == 'test' then
      local extension = vim.fn.matchstr(vim.fn.fnamemodify(filepath, ':t'), '\\(test\\|spec\\)\\..*')
      local icon, _ = devicons.get_icon(entry.filename, extension)
      return icon .. ' '
    else
      return ''
    end
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local results = read_test_titles_from(filepath)

  pickers
    .new(opts, {
      prompt_title = 'Tests',
      finder = finders.new_table {
        results = results,
        entry_maker = function(entry)
          local indent_markers = get_indent_markers(entry)
          local icon = get_icon(entry, filepath)
          local description = indent_markers .. icon .. entry.description

          return {
            bufnr = bufnr,
            display = make_display,
            filename = filepath,
            lnum = entry.line,
            ordinal = description,
            value = description,
          }
        end,
      },
      sorter = config.generic_sorter(opts),
      previewer = config.grep_previewer(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.api.nvim_win_set_cursor(0, { entry.lnum, 0 })
        end)
        return true
      end,
    })
    :find()
end

return M
