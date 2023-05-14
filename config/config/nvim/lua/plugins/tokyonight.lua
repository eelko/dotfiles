return {
  'folke/tokyonight.nvim',
  event = 'VimEnter',
  config = function()
    require('tokyonight').setup {
      sidebars = { 'coctree', 'list', 'qf' },
      on_highlights = function(hl, c)
        local my_colors = { arsenic = '#414141' }

        hl.DiffDelete = { bg = c.diff.delete, fg = c.diff.delete }
        hl.FloatBorder = { bg = my_colors.arsenic, fg = 'Grey' }
        hl.FoldColumn = { bg = 'none', fg = c.comment }
        hl.Folded = { link = 'Comment' }
        hl.NormalFloat = { bg = my_colors.arsenic }
        hl.SignColumn = { bg = 'none', fg = c.comment }
        hl.StatusLine = { bg = c.fg_gutter, fg = c.fg_sidebar }
        hl.WinBarNC = { fg = 'Grey', bold = true }

        -- Bufferline
        hl.BufferLineCloseButtonSelected = { fg = c.dark5, sp = c.blue, underline = true }
        hl.BufferLineIndicatorSelected = { link = 'BufferLineSeparatorSelected' } -- underline for entire "tab"
        hl.BufferLineNumbersSelected = { fg = c.dark5, bg = c.bg, sp = c.blue, underline = true }

        -- CoC colors
        hl.CocHighlightText = { link = 'LspReferenceText' }
        -- completion menu
        hl.CocPumSearch = { link = 'CmpItemAbbrMatch' }
        hl.CocPumShortcut = { fg = 'Grey' }
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
        -- hl.CocSymbolText = { link = '' }
        hl.CocSymbolTypeParameter = { link = 'CmpItemKindTypeParameter' }
        hl.CocSymbolUnit = { link = 'CmpItemKindUnit' }
        hl.CocSymbolValue = { link = 'CmpItemKindValue' }
        hl.CocSymbolVariable = { link = 'CmpItemKindVariable' }
        -- list
        hl.CocListMode = { fg = c.fg_dark, bg = c.bg_dark }
        hl.CocListPath = { fg = c.fg_dark, bg = c.bg_dark }
        -- outline
        hl.CocTreeOpenClose = { link = 'NvimTreeIndentMarker' }

        -- Indent Blank Line
        hl.IndentBlanklineSpaceChar = { link = 'NonText' }

        -- Telescope
        local prompt = '#2d3149'
        -- normal
        hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
        hl.TelescopePromptNormal = { bg = prompt }
        hl.TelescopePreviewNormal = { bg = c.border }
        -- borders
        hl.TelescopeBorder = { bg = c.bg_dark, fg = c.bg_dark }
        hl.TelescopePromptBorder = { bg = prompt, fg = prompt }
        hl.TelescopePreviewBorder = { bg = c.border, fg = c.border }
        -- title
        hl.TelescopePromptTitle = { bg = prompt, fg = c.fg_dark }
        hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }
        hl.TelescopePreviewTitle = { bg = c.border, fg = c.border }

        -- Treesitter
        hl.TreesitterContext = { bg = c.bg_highlight }
        hl.TreesitterContextBottom = { sp = c.border, underline = true }
        hl.TreesitterContextLineNumber = { bg = c.bg_highlight, fg = c.dark5 }
      end,
    }

    vim.cmd 'colorscheme tokyonight'
  end,
}
