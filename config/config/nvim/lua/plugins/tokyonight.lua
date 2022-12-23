return {
  'folke/tokyonight.nvim',
  config = function()
    require('tokyonight').setup {
      sidebars = { 'coctree', 'list', 'qf' },
      on_highlights = function(hl, c)
        hl.DiffDelete = { bg = c.diff.delete, fg = c.diff.delete }
        hl.FloatBorder = { fg = 'grey', bg = '#414141' }
        hl.Folded = { link = 'Comment' }
        hl.NormalFloat = { bg = '#414141' }

        -- CoC colors
        -- completion menu
        hl.CocPumSearch = { link = 'CmpItemAbbrMatch' }
        hl.CocPumShortcut = { fg = 'grey' }
        -- completion kinds
        hl.CocSymbolClass = { link = 'CmpItemKindClass' }
        hl.CocSymbolConstant = { link = 'CmpItemKindConstant' }
        hl.CocSymbolConstructor = { link = 'CmpItemKindConstructor' }
        hl.CocSymbolDefault = { link = 'CmpItemKindDefault' }
        hl.CocSymbolEnum = { link = 'CmpItemKindEnum' }
        hl.CocSymbolEnumMember = { link = 'CmpItemKindEnumMember' }
        hl.CocSymbolEvent = { link = 'CmpItemKindEvent' }
        hl.CocSymbolField = { link = 'CmpItemKindField' }
        hl.CocSymbolFile = { link = 'Normal' }
        hl.CocSymbolFunction = { link = 'CmpItemKindFunction' }
        hl.CocSymbolInterface = { link = 'CmpItemKindInterface' }
        hl.CocSymbolKeyword = { link = 'CmpItemKindKeyword' }
        hl.CocSymbolMethod = { link = 'CmpItemKindMethod' }
        hl.CocSymbolModule = { link = 'CmpItemKindModule' }
        hl.CocSymbolOperator = { link = 'CmpItemKindOperator' }
        hl.CocSymbolProperty = { link = 'CmpItemKindProperty' }
        hl.CocSymbolReference = { link = 'CmpItemKindReference' }
        hl.CocSymbolSnippet = { link = 'CmpItemKindSnippet' }
        hl.CocSymbolStruct = { link = 'CmpItemKindStruct' }
        hl.CocSymbolText = { link = '' }
        hl.CocSymbolTypeParameter = { link = 'CmpItemKindTypeParameter' }
        hl.CocSymbolUnit = { link = 'CmpItemKindUnit' }
        hl.CocSymbolValue = { link = 'CmpItemKindValue' }
        hl.CocSymbolVariable = { link = 'CmpItemKindVariable' }
        -- list
        hl.CocListMode = { fg = c.fg_dark, bg = c.bg_dark }
        hl.CocListPath = { fg = c.fg_dark, bg = c.bg_dark }
        -- outline
        hl.CocTreeOpenClose = { link = 'NvimTreeIndentMarker' }
      end,
    }

    vim.cmd 'colorscheme tokyonight'
  end,
}
