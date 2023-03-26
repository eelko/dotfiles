return {
  'nvim-tree/nvim-web-devicons',
  config = function()
    local devicons = require 'nvim-web-devicons'

    -- override icons but reuse original colors
    local _, js_color = devicons.get_icon_color('foo.js', 'js')
    local _, md_color = devicons.get_icon_color('foo.md', 'markdown')
    local _, ts_color = devicons.get_icon_color('foo.ts', 'ts')

    devicons.set_icon {
      ['js'] = {
        icon = '󰌞',
        color = js_color,
        name = 'Js',
      },
      ['md'] = {
        icon = '',
        color = md_color,
        name = 'Md',
      },
      ['ts'] = {
        icon = '󰛦',
        color = ts_color,
        name = 'Ts',
      },
    }
  end,
}
