local packer_present, packer = pcall(require, 'plugins.packer')

if not packer_present then
  return false
end

require 'helpers'

-- Regenerate compiled loader file whenever this file is updated
cmd [[
  augroup PackerUserConfig
    autocmd!
    autocmd BufWritePost *.lua source <afile> | PackerCompile
  augroup end
]]

-- Declare plugins
return packer.startup(function(use)
  -- Let Packer manage itself
  use { 'wbthomason/packer.nvim' }

  -- Colors
  use {
    'sjl/badwolf',
    config = function()
      cmd [[
      function! SanitizeColors()
        hi CursorLine guibg=#444444
        hi IncSearch guifg=#353b45 guibg=#d19a66
        hi LineNr guibg=NONE
        hi MatchParen guibg=NONE
        hi Normal guibg=NONE
        hi NormalNC guibg=#3a3a3a
        hi Pmenu guifg=#f8f6f2 guibg=#484A55
        hi PmenuSbar guibg=#2B2C31
        hi PmenuThumb guibg=grey
        hi Search guifg=#353b45 guibg=#e5c07b
        hi SignColumn guibg=NONE
        hi StatusLineNC gui=bold guifg=gray guibg=#262626
        hi VertSplit guifg=#3a3a3a guibg=#3a3a3a
        hi Visual guibg=#626262

        hi! link ColorColumn CursorLine
        hi! link Error ErrorMsg
        hi! link PmenuSel Search

        if g:colors_name == 'badwolf'
          hi DiffAdd guibg=#143800
          hi DiffDelete guibg=#380000
          hi Noise guifg=#949494
          hi NonText guibg=NONE
          hi QuickFixLine gui=NONE guibg=#32302f
          hi! link StatusLine StatusLineNormal
          hi! link jsxBraces Noise
          hi! link typescriptBraces Noise
          hi! link typescriptParens Noise
          hi! link typescriptImport Include
          hi! link typescriptExport Include
          hi! link typescriptVariable typescriptAliasKeyword
          hi! link typescriptBOM Normal
        endif
      endf

      autocmd ColorScheme * call SanitizeColors()
      ]]
      cmd 'colorscheme badwolf'
    end,
  }

  -- Tabline aesthetics
  use {
    'ap/vim-buftabline',
    config = function()
      opt('g', 'buftabline_show', true)
      opt('g', 'buftabline_indicators', true)
      opt('g', 'buftabline_numbers', 2)
      map('n', '<leader>1', '<Plug>BufTabLine.Go(1)', { noremap = false })
      map('n', '<leader>2', '<Plug>BufTabLine.Go(2)', { noremap = false })
      map('n', '<leader>3', '<Plug>BufTabLine.Go(3)', { noremap = false })
      map('n', '<leader>4', '<Plug>BufTabLine.Go(4)', { noremap = false })
      map('n', '<leader>5', '<Plug>BufTabLine.Go(5)', { noremap = false })
      map('n', '<leader>6', '<Plug>BufTabLine.Go(6)', { noremap = false })
      map('n', '<leader>7', '<Plug>BufTabLine.Go(7)', { noremap = false })
      map('n', '<leader>8', '<Plug>BufTabLine.Go(8)', { noremap = false })
      map('n', '<leader>9', '<Plug>BufTabLine.Go(9)', { noremap = false })
      map('n', '<leader>0', '<Plug>BufTabLine.Go(10)', { noremap = false })
      cmd [[
        hi BufTabLineCurrent gui=bold guibg=#ff5f5f guifg=#080808
        hi BufTabLineActive  gui=bold guibg=#3a3a3a guifg=#ff5f5f
        hi BufTabLineHidden  gui=bold guibg=#3a3a3a guifg=#D5C4A1
        hi BufTabLineFill    gui=bold guibg=#3a3a3a guifg=#D5C4A1
      ]]
    end,
  }

  -- Language pack
  use {
    'sheerun/vim-polyglot',
    config = function()
      opt('g', 'vim_markdown_conceal', false)
      opt('g', 'vim_markdown_conceal_code_blocks', false)
    end,
  }

  -- Git sings on gutter
  use {
    'mhinz/vim-signify',
    config = function()
      opt('g', 'signify_sign_show_count', false)
      opt('g', 'signify_priority', 5)
      opt('g', 'signify_sign_add', '│')
      opt('g', 'signify_sign_delete', '│')
      opt('g', 'signify_sign_delete_first_line', '│')
      opt('g', 'signify_sign_change', '│')
      opt('g', 'signify_sign_changedelete', '│')
      cmd [[
        hi SignifySignAdd    guifg=#9BB76D guibg=NONE
        hi SignifySignChange guifg=#00AFFF guibg=NONE
        hi SignifySignDelete guifg=#FF5F5F guibg=NONE
      ]]
    end,
  }

  -- Indentation guides
  use {
    'yggdroot/indentLine',
    config = function()
      opt('g', 'indentLine_faster', 1)
      opt('g', 'indentLine_char', '┊')
    end,
  }

  -- Auto pairs
  use {
    'tmsvg/pear-tree',
    config = function()
      opt('g', 'pear_tree_repeatable_expand', false)
      cmd 'au FileType * imap <buffer> <Space> <Plug>(PearTreeSpace)'
    end,
  }

  -- Tmux integration
  use {
    'christoomey/vim-tmux-navigator',
    config = function()
      opt('g', 'tmux_navigator_no_mappings', true)
      map('n', '<m-h>', ':TmuxNavigateLeft<CR>')
      map('n', '<m-j>', ':TmuxNavigateDown<CR>')
      map('n', '<m-k>', ':TmuxNavigateUp<CR>')
      map('n', '<m-l>', ':TmuxNavigateRight<CR>')
    end,
  }

  -- File explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      opt('g', 'nvim_tree_git_hl', 0)
      opt('g', 'nvim_tree_icons', { default = '', symlink = '' })
      opt('g', 'nvim_tree_ignore', { '.git' })
      opt('g', 'nvim_tree_indent_markers', 1)
      opt('g', 'nvim_tree_show_icons', { git = 0, folders = 1, files = 1 })
      opt('g', 'nvim_tree_root_folder_modifier', ':t')

      map('n', '<leader>nf', ':NvimTreeFindFile<CR>')
      map('n', '<leader>nt', ':NvimTreeToggle<CR>')

      local tree_cb = require('nvim-tree.config').nvim_tree_callback

      require('nvim-tree').setup {
        hijack_cursor = true, -- hijack the cursor in the tree to put it at the start of the filename
        update_focused_file = {
          enable = true, -- highlight current file
        },
        view = {
          mappings = {
            list = {
              -- NERDTree-like mappings
              { key = 'C', cb = tree_cb 'cd' },
              { key = 'u', cb = tree_cb 'dir_up' },
              { key = 'x', cb = tree_cb 'close_node' },
            },
          },
        },
      }
    end,
  }

  -- Quickly comment code
  use { 'tpope/vim-commentary' }

  -- Turn quickfix buffer editable
  use { 'itchyny/vim-qfedit' }

  -- Readline keymaps for command bar
  use { 'tpope/vim-rsi' }

  -- Quickly surround with quotes/parens/etc
  use { 'tpope/vim-surround', requires = { 'tpope/vim-repeat' } }

  -- Markdown previewer
  use { 'iamcco/markdown-preview.nvim', run = ':call mkdp#util#install()' }

  -- Documentation generator
  use {
    'kkoomen/vim-doge',
    run = ':call doge#install()',
    config = function()
      opt('g', 'doge_enable_mappings', 0)
    end,
  }

  -- Statusline
  use {
    'tamton-aquib/staline.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require 'plugins.statusline'
    end,
  }

  -- Faster text navigation
  use {
    'justinmk/vim-sneak',
    config = function()
      opt('g', 'sneak#label', 1)
    end,
  }

  -- Project configurations
  use {
    'tpope/vim-projectionist',
    config = function()
      map('n', '<leader>aa', ':A<CR>')
      map('n', '<leader>as', ':AS<CR>')
      map('n', '<leader>av', ':AV<CR>')
    end,
  }

  -- Actions with motions
  use {
    'obxhdx/vim-action-mapper',
    config = function()
      function _G.find_and_replace(text, type)
        local visual_modes = { 'v', '^V' }
        local use_word_boundary = not _G.contains(visual_modes, type)
        local pattern = use_word_boundary and '\\<' .. text .. '\\>' or text
        local new_text = vim.fn.input('Replace ' .. pattern .. ' with: ', text)

        if #new_text > 0 then
          _G.exec_preserving_cursor_pos(',$s/' .. pattern .. '/' .. new_text .. '/gc')
        end
      end

      cmd [[
        function! FindAndReplace(text, type)
          call v:lua.find_and_replace(a:text, a:type)
        endfunction
        autocmd User MapActions call MapAction('FindAndReplace', '<Leader>r')

        function! GrepWithMotion(text, type)
          execute('Grep '.a:text)
        endfunction
        autocmd User MapActions call MapAction('GrepWithMotion', '<Leader>g')
      ]]
    end,
  }

  -- Easily add debug messages
  use {
    'obxhdx/vim-debug-logger',
    requires = 'obxhdx/vim-action-mapper',
    config = function()
      map('n', '<leader>lc', ':CommentAllDebugLogs<CR>')
      map('n', '<leader>ld', ':DeleteAllDebugLogs<CR>')
      map('n', '<leader>lu', ':UncommentAllDebugLogs<CR>')
    end,
  }

  -- FZF
  use {
    'junegunn/fzf.vim',
    requires = {
      { 'junegunn/fzf', run = ':call fzf#install()' },
    },
    config = function()
      opt('g', 'fzf_layout', { window = { width = 0.7, height = 0.4 } })
      opt('g', 'projectionist_ignore_term', 1)
      map('n', '<leader>fb', ':Buffers<CR>')
      map('n', '<leader>fc', ':Commands<CR>')
      map('n', '<leader>ff', ':Files<CR>')
      map('n', '<leader>fh', ':History:<CR>')
      map('n', '<leader>fl', ':BLines<CR>')
      map('n', '<leader>fr', ':History<CR>')
      map('n', '<leader>rg', ':Rg<CR>')
      cmd [[
    command! -bang -nargs=* Rg call fzf#vim#grep('rg --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1, fzf#vim#with_preview({'options': ['--preview-window=up:60%']}), <bang>0)
  ]]
    end,
  }

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {
      'JoosepAlviste/nvim-ts-context-commentstring',
      'nvim-treesitter/nvim-treesitter-refactor',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      opt('w', 'foldmethod', 'expr')
      opt('w', 'foldexpr', 'nvim_treesitter#foldexpr()')

      require('nvim-treesitter.configs').setup {
        ensure_installed = 'maintained',
        -- Context aware comments (nvim-ts-context-commentstring)
        context_commentstring = {
          enable = true,
        },
        -- Better code navigation (nvim-treesitter-refactor)
        refactor = {
          highlight_definitions = { enable = true },
          navigation = {
            enable = true,
            keymaps = {
              goto_definition = 'gd',
              goto_next_usage = ']u',
              goto_previous_usage = '[u',
            },
          },
        },
        -- Additional text ojbects (nvim-treesitter-textobjects)
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['ib'] = '@block.inner',
              ['ab'] = '@block.outer',
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
        },
      }
    end,
  }

  -- CoC
  use {
    'neoclide/coc.nvim',
    opt = true,
    branch = 'release',
    requires = {
      -- FZF integration
      'antoinemadec/coc-fzf',
      -- General purpose LSP
      'tsuyoshicho/vim-efm-langserver-settings',
      -- Visual hint when code actions are available
      'xiyaowong/coc-lightbulb',
    },
    config = function()
      require 'plugins.coc'
    end,
  }

  -- Native LSP
  use {
    'neovim/nvim-lspconfig',
    requires = {
      -- LSP server installer
      'williamboman/nvim-lsp-installer',
      -- Visual hint when code actions are available
      { 'kosayoda/nvim-lightbulb', commit = '3c5d42a' },
      -- Quickfix alternative for diagnostics, references, etc
      'HungryJoe/trouble.nvim',
      -- Method signature hints
      'ray-x/lsp_signature.nvim',
      -- General purpose LSP
      { 'jose-elias-alvarez/null-ls.nvim', requires = { 'nvim-lua/plenary.nvim' } },
      -- Enhanced LSP experience for TS
      { 'jose-elias-alvarez/nvim-lsp-ts-utils', requires = { 'nvim-lua/plenary.nvim' } },
      -- Code Completion
      {
        'hrsh7th/nvim-cmp',
        requires = {
          'hrsh7th/cmp-buffer',
          'hrsh7th/cmp-nvim-lsp',
          'hrsh7th/cmp-path',
          'hrsh7th/cmp-vsnip',
          'onsails/lspkind-nvim',
          -- Snippets
          { 'hrsh7th/vim-vsnip', requires = { 'hrsh7th/vim-vsnip-integ', 'rafamadriz/friendly-snippets' } },
        },
      },
    },
    config = function()
      require 'plugins.lsp'
    end,
  }
end)
