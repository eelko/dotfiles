return {
  'luukvbaal/statuscol.nvim',
  event = 'UIEnter',
  config = function()
    local builtin = require 'statuscol.builtin'
    require('statuscol').setup {
      relculright = true,
      segments = {
        {
          text = { ' ', builtin.foldfunc, ' ' },
          -- condition = { builtin.not_empty, true, builtin.not_empty },
          condition = false,
          click = 'v:lua.ScFa',
        },
        { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
        {
          sign = { name = { '.*' }, maxwidth = 2, colwidth = 1, auto = false },
          click = 'v:lua.ScSa',
        },
      },
    }
  end,
}
