local wezterm = require 'wezterm'
local icons = wezterm.nerdfonts
local act = wezterm.action

local BASE_THEME = 'Catppuccin Macchiato'
local colors = wezterm.color.get_builtin_schemes()[BASE_THEME]

colors.tab_bar = {
  background = colors.background,
  active_tab = {
    bg_color = colors.background,
    fg_color = colors.foreground,
  },
  inactive_tab = {
    bg_color = colors.background,
    fg_color = colors.brights[5], -- blue
  },
  inactive_tab_hover = {
    bg_color = colors.background,
    fg_color = colors.brights[5], -- blue
  },
}

local function get_current_working_dir(tab)
  local current_dir = tab.active_pane.current_working_dir
  local HOME_DIR = string.format('file://%s', os.getenv 'HOME')

  return current_dir == HOME_DIR and '~' or string.format('%s', string.gsub(current_dir, '(.*[/\\])(.*)', '%2'))
end

local function get_process(tab)
  local process_icons = {
    ['bash'] = {
      { Foreground = { Color = 'Grey' } },
      { Text = icons.dev_terminal },
      { Text = '  ' }, -- extra space process and folder icons
    },
    ['docker-compose'] = {
      { Foreground = { AnsiColor = 'Aqua' } },
      { Text = icons.linux_docker },
      { Text = '  ' }, -- extra space process and folder icons
    },
    ['git'] = {
      { Foreground = { AnsiColor = 'Maroon' } },
      { Text = icons.mdi_git },
      { Text = '  ' }, -- extra space process and folder icons
    },
    ['node'] = {
      { Foreground = { Color = 'Lime' } },
      { Text = icons.dev_nodejs_small },
      { Text = '  ' }, -- extra space process and folder icons
    },
    ['nvim'] = {
      { Foreground = { AnsiColor = 'Green' } },
      { Text = icons.custom_vim },
      { Text = '  ' }, -- extra space process and folder icons
    },
    ['vim'] = {
      { Foreground = { AnsiColor = 'Green' } },
      { Text = icons.dev_vim },
      { Text = '  ' }, -- extra space process and folder icons
    },
    ['zsh'] = {
      { Foreground = { Color = 'Grey' } },
      { Text = icons.dev_terminal },
      { Text = '  ' }, -- extra space process and folder icons
    },
  }

  local process_name = string.gsub(tab.active_pane.foreground_process_name, '(.*[/\\])(.*)', '%2')
  local fallback = { { Text = '' } }

  return wezterm.format(process_icons[process_name] or fallback)
end

wezterm.on('format-tab-title', function(tab)
  return wezterm.format {
    -- Tab index
    { Text = ' ' },
    { Attribute = { Italic = true } },
    { Foreground = { Color = 'Grey' } },
    { Text = string.format('%s ', tab.tab_index + 1) },
    { Text = ' ' },
    'ResetAttributes',

    -- Process icon
    { Text = get_process(tab) },

    -- Folder icon
    { Foreground = { AnsiColor = 'Silver' } },
    { Text = wezterm.nerdfonts.custom_folder_open },
    { Text = ' ' },
    'ResetAttributes',

    -- Current dir
    { Attribute = { Italic = true } },
    { Text = get_current_working_dir(tab) },
    { Text = '   ' },
  }
end)

wezterm.on('update-right-status', function(window)
  local date = wezterm.strftime '%a %b %e %l:%M %p '

  window:set_right_status(wezterm.format {
    { Attribute = { Italic = true } },
    { Foreground = { Color = colors.brights[5] } },
    { Text = date .. wezterm.nerdfonts.mdi_calendar_clock .. ' ' },
  })
end)

return {
  -- Misc
  default_prog = { '/usr/local/bin/fish', '-l' },
  default_cursor_style = 'SteadyUnderline',

  -- Colors
  color_schemes = {
    ['Custom'] = colors,
  },
  color_scheme = 'Custom',

  -- Font
  font = wezterm.font('OperatorMono NF', { weight = 'Book' }),
  font_size = 14.0,
  underline_thickness = 3,
  underline_position = -4,

  -- Tab bar
  tab_bar_at_bottom = true,
  tab_max_width = 50,
  use_fancy_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,

  -- Window appearance
  initial_cols = 115,
  initial_rows = 35,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },

  mouse_bindings = {
    { -- select the complete output from a command
      event = { Down = { streak = 4, button = 'Left' } },
      action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
      mods = 'NONE',
    },
  },

  -- Keys
  -- Default Key Assignments https://wezfurlong.org/wezterm/config/default-keys.html
  keys = {
    -- Cycle throuth the start of an earlier/later command
    { mods = 'SHIFT', key = 'UpArrow', action = act.ScrollToPrompt(-1) },
    { mods = 'SHIFT', key = 'DownArrow', action = act.ScrollToPrompt(1) },

    -- Misc
    { mods = 'SUPER', key = 'Enter', action = act.ToggleFullScreen },
    { mods = 'SUPER', key = 'w', action = act.CloseCurrentPane { confirm = true } },
    { mods = 'SUPER', key = 'z', action = act.TogglePaneZoomState },

    -- Creating panes
    { mods = 'SUPER', key = 'D', action = act { SplitVertical = { domain = 'CurrentPaneDomain' } } },
    { mods = 'SUPER', key = 'd', action = act { SplitHorizontal = { domain = 'CurrentPaneDomain' } } },

    -- Navigating panes
    { mods = 'SUPER', key = 'h', action = act { ActivatePaneDirection = 'Left' } },
    { mods = 'SUPER', key = 'j', action = act { ActivatePaneDirection = 'Down' } },
    { mods = 'SUPER', key = 'k', action = act { ActivatePaneDirection = 'Up' } },
    { mods = 'SUPER', key = 'l', action = act { ActivatePaneDirection = 'Right' } },

    -- Cycling through tabs
    { mods = 'SUPER|ALT', key = 'LeftArrow', action = act { ActivateTabRelative = -1 } },
    { mods = 'SUPER|ALT', key = 'RightArrow', action = act { ActivateTabRelative = 1 } },

    -- Moving tabs
    { mods = 'SUPER|SHIFT', key = 'LeftArrow', action = act { MoveTabRelative = -1 } },
    { mods = 'SUPER|SHIFT', key = 'RightArrow', action = act { MoveTabRelative = 1 } },

    -- Fix readline "undo"
    { mods = 'CTRL', key = '/', action = act { SendString = '\x1f' } },
  },
}
