vim.cmd[[ au VimEnter * hi! StatusLine guifg=white guibg=NONE ]]

local gl = require('galaxyline')

local gls = gl.section
gl.short_line_list = { 'defx', 'packager', 'vista' }

-- Colors
local colors = {
  bg = '#282a36',
  blue = '#8be9fd',
  cyan = '#8be9fd',
  fg = '#d3d3d3',
  green = '#50fa7b',
  magenta = '#ff4db2',
  orange = '#ff8700',
  red = '#ff5555',
  section_bg = '#38393f',
  yellow = '#f1fa8c',
}

-- Local helper functions
local has_width_gt = function(cols)
  -- Check if the windows width is greater than a given number of columns
  return vim.fn.winwidth(0) / 2 > cols
end

local buffer_not_empty = function()
  return vim.fn.empty(vim.fn.expand('%:t')) == 0
end

local checkwidth = function()
  return has_width_gt(40) and buffer_not_empty()
end

local is_git_dir = function()
  return vim.fn.exists('*sy#repo#get_stats') == 1
end

-- local has_diagnostics = function()
--   local has_info, info = pcall(vim.fn.nvim_buf_get_var, 0, 'coc_diagnostic_info')
--   if not has_info then return end
--   for k, v in pairs(info) do
--     if tonumber(v) ~= nil and tonumber(v) > 0 then
--       return true
--     end
--   end
-- end

local mode_color = function()
  local mode_colors = {
    n = colors.green,
    i = colors.cyan,
    c = colors.magenta,
    V = colors.orange,
    [''] = colors.orange,
    v = colors.orange,
    R = colors.red,
    r = colors.red,
  }
  return mode_colors[vim.fn.mode()]
end

local separators = {
  filled_left = '', -- e0b0
  filled_right = '', -- e0b2
  left = '', -- e0b1
  right = '', -- e0b3
  lower_left = '', -- e0b8
  lower_right = '', -- e0ba
  pipe = '|',
}

local icons = {
  connected = '', -- f817
  diff_add = '', -- f457
  diff_modified = '', -- f459
  diff_remove = '', -- f458
  disconnected = '', -- f818
  dos = '', -- e70f
  error = '', -- f658
  git = '', -- f841
  info = '', -- f05a
  line_number = '', -- e0a1
  locker = '', -- f023
  mac = '', -- f179
  not_modifiable = '', -- f05e
  page = '☰', -- 2630
  pencil = '', -- f040
  unix = '', -- f17c
  unsaved = '', -- f0c7
  warning = '', -- f06a
  wrench = '', -- f0ad
}

-- Left side
gls.left[1] = {
  FirstElement = {
    provider = function() return ' ' end,
    highlight = { colors.bg, colors.bg }
  },
}
gls.left[2] = {
  ViMode = {
    provider = function()
      if mode_color() ~= nil then
        vim.api.nvim_command('hi GalaxyViMode gui=bold guifg='..mode_color())
      end
      local mode_names = {
        n = 'NORMAL',
        i = 'INSERT',
        c = 'COMMAND',
        V = 'VISUAL',
        [''] = 'VISUAL',
        v = 'VISUAL',
        R = 'REPLACE',
        r = 'CONFIRM',
      }
      local mode = mode_names[vim.fn.mode()]
      -- return mode ~= nil and mode..' ' or ''
      return mode ~= nil and mode or ''
    end,
    highlight = { colors.bg, colors.bg },
    separator = separators.lower_left..' ',
    separator_highlight = { colors.bg, colors.section_bg },
  },
}
gls.left[3] ={
  FileIcon = {
    provider = 'FileIcon',
    highlight = { require('galaxyline.provider_fileinfo').get_file_icon_color, colors.section_bg },
  },
}
gls.left[4] = {
  FileName = {
    provider = { 'FileName', 'FileSize' },
    highlight = { colors.fg, colors.section_bg },
    separator = separators.lower_left,
    separator_highlight = { colors.section_bg, colors.bg },
  }
}
-- Git
gls.left[5] = {
  GitIcon = {
    provider = function() return '  '..icons.git..' ' end,
    condition = checkwidth,
    highlight = { colors.red, colors.bg },
  }
}
gls.left[6] = {
  GitBranch = {
    provider = 'GitBranch',
    condition = checkwidth,
    highlight = { colors.fg, colors.bg },
  }
}
gls.left[7] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.green, colors.bg },
  }
}
gls.left[8] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.orange, colors.bg },
  }
}
gls.left[9] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.red, colors.bg },
  }
}
-- Diagnostics
gls.left[10] = {
  LeftEnd = {
    provider = function() return '' end,
    highlight = { colors.section_bg, colors.bg },
    separator = separators.lower_right..' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}
gls.left[11] = {
  CocStatus = {
    provider = function()
      local has_status, status = pcall(vim.fn.nvim_get_var, 'coc_status')
      return has_status and status or ''
    end,
    highlight = { colors.fg, colors.section_bg }
  }
}
gls.left[12] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  '..icons.error..' ',
    highlight = { colors.red, colors.section_bg }
  }
}
gls.left[13] = {
  Space = {
    provider = function () return '' end,
    highlight = { colors.section_bg, colors.section_bg },
  }
}
gls.left[14] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  '..icons.warning..' ',
    highlight = { colors.orange, colors.section_bg },
  }
}
gls.left[15] = {
  Space = {
    provider = function () return '' end,
    highlight = {colors.section_bg, colors.section_bg},
  }
}
gls.left[16] = {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  '..icons.info..' ',
    highlight = { colors.blue, colors.section_bg },
  }
}
gls.left[17] = {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '  '..icons.wrench..' ',
    highlight = { colors.fg, colors.section_bg },
  }
}
gls.left[18] = {
  RightEnd = {
    provider = function() return '°' end,
    highlight = { colors.section_bg, colors.section_bg },
    separator = separators.lower_left,
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

-- Right side
gls.right[1]= {
  Separator = {
    provider = function() return '' end,
    highlight = { colors.fg, colors.section_bg },
    separator = separators.lower_right..' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}
gls.right[2]= {
  FileFormat = {
    provider = function() return ' '..vim.bo.filetype end,
    condition = checkwidth,
    highlight = { colors.fg, colors.section_bg },
    separator_highlight = { colors.section_bg, colors.bg },
  }
}
gls.right[3] = {
  Separator2 = {
    provider = function() return '' end,
    condition = checkwidth,
    highlight = { colors.fg, colors.section_bg },
    separator = ' '..separators.pipe..' ',
    separator_highlight = { colors.bg, colors.section_bg },
  },
}
gls.right[4] = {
  LineInfo = {
    provider = 'LineColumn',
    highlight = { colors.fg, colors.section_bg },
    separator_highlight = { colors.bg, colors.section_bg },
  },
}
gls.right[5] = {
  LinePercent = {
    provider = 'LinePercent',
    highlight = { colors.fg, colors.section_bg },
    separator = ' '..separators.pipe,
    separator_highlight = { colors.bg, colors.section_bg },
  }
}

-- Short status line
gls.short_line_left[1] = {
  BufferType = {
    provider = 'FileName',
    highlight = { colors.fg, colors.bg },
    separator = separators.lower_right..' ',
    separator_highlight = { colors.bg, colors.bg },
  }
}

-- Force manual load so that nvim boots with a status line
gl.load_galaxyline()
