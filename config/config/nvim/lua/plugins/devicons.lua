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
        icon = '',
        color = js_color,
        name = 'Js',
      },
      ['md'] = {
        icon = '',
        color = md_color,
        name = 'Md',
      },
      ['test.js'] = {
        icon = '',
        color = js_color,
        name = 'TestJavascript',
      },
      ['test.jsx'] = {
        icon = '',
        color = js_color,
        name = 'TestJavascriptReact',
      },
      ['test.ts'] = {
        icon = '',
        color = ts_color,
        name = 'TestTypescript',
      },
      ['test.tsx'] = {
        icon = '',
        color = ts_color,
        name = 'TestTypescriptReact',
      },
      ['ts'] = {
        icon = 'ﯤ',
        color = ts_color,
        name = 'Ts',
      },
    }
  end,
}
