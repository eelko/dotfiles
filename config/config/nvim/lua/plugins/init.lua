require 'utils'

-- Bootstrap Packer
local packer_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
  packer_bootstrap = vim.fn.system {
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    packer_path,
  }

  vim.cmd 'packadd packer.nvim'
end

-- Auto-regenerate compiled Packer loader
vim.cmd [[
  augroup PackerUserConfig
    autocmd!
    autocmd BufWritePost */nvim/lua/*.lua source <afile> | PackerCompile
  augroup end
]]

-- Declare plugins
return require('packer').startup {
  function(use)
    -- Let Packer manage itself
    use {
      'wbthomason/packer.nvim',
      config = function()
        local packer = require 'packer'

        local function packer_lock()
          local util = require 'packer.util'
          local snapshot_file = util.join_paths(vim.fn.stdpath 'config', 'packer-lock.json')
          local temp_file = vim.fn.tempname()

          packer.snapshot(snapshot_file)

          -- format snapshot
          vim.defer_fn(function()
            os.execute('jq --sort-keys . ' .. snapshot_file .. '> ' .. temp_file)
            os.rename(temp_file, snapshot_file)
          end, 1000)
        end

        local function packer_sync_and_lock()
          local augroup = vim.api.nvim_create_augroup('PackerSyncAndLock', { clear = true })

          vim.api.nvim_create_autocmd('User', {
            pattern = 'PackerComplete',
            callback = function()
              packer_lock()
              vim.api.nvim_del_augroup_by_id(augroup)
            end,
            group = augroup,
          })

          packer.sync()
        end

        vim.api.nvim_create_user_command('PackerLock', packer_lock, {})
        vim.api.nvim_create_user_command('PackerSyncAndLock', packer_sync_and_lock, {})
      end,
    }

    -- Improve startup time
    use { 'lewis6991/impatient.nvim' }

    -- Colors
    use {
      'folke/tokyonight.nvim',
      event = 'UIEnter',
      config = function()
        require('tokyonight').setup {
          sidebars = { 'coctree', 'list', 'qf' },
          on_highlights = function(hl, c)
            -- Core colors
            hl.DiffDelete = { bg = '#3f2d3d', fg = '#3f2d3d' }
            hl.Folded = { link = 'Comment' }
            hl.FloatBorder = { fg = 'grey' }

            -- LSP diagnostics colors
            hl.DiagnosticVirtualTextError = { bg = '#362c3d', fg = c.error, italic = true }
            hl.DiagnosticVirtualTextHint = { bg = '#233745', fg = c.hint, italic = true }
            hl.DiagnosticVirtualTextInfo = { bg = '#22374b', fg = c.info, italic = true }
            hl.DiagnosticVirtualTextWarn = { bg = '#373640', fg = c.warning, italic = true }

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

            -- Misc plugins colors
            hl.IndentBlanklineContextChar = { bg = c.none, fg = c.comment, nocombine = true }
            hl.NvimTreeFolderIcon = { bg = c.none, fg = '#8094b4' } -- classic folder color
          end,
        }

        vim.cmd 'color tokyonight'
      end,
    }

    -- Icons
    use {
      'nvim-tree/nvim-web-devicons',
      event = 'UIEnter',
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

    -- Tabline
    use {
      'akinsho/bufferline.nvim',
      after = 'tokyonight.nvim',
      config = function()
        vim.o.mousemoveevent = true

        require('bufferline').setup {
          highlights = {
            buffer_selected = {
              fg = '#a9b1d6',
              bold = false,
              italic = false,
            },
            close_button_selected = {
              fg = '#565f89',
            },
          },
          options = {
            buffer_close_icon = '',
            diagnostics = false,
            hover = {
              enabled = true,
              delay = 100,
              reveal = { 'close' },
            },
            max_name_length = 50,
            modified_icon = '',
            offsets = {
              {
                filetype = 'NvimTree',
                text = function()
                  return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
                end,
                text_align = 'center',
              },
            },
          },
        }
      end,
    }

    -- Git sings on gutter
    use {
      'lewis6991/gitsigns.nvim',
      after = 'tokyonight.nvim',
      requires = { 'nvim-lua/plenary.nvim', opt = true },
      config = function()
        require('gitsigns').setup {
          signs = {
            add = { hl = 'GitSignsAdd', text = '▎', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
            change = { hl = 'GitSignsChange', text = '▎', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
            delete = { hl = 'GitSignsDelete', text = '▎', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
            topdelete = {
              hl = 'GitSignsDelete',
              text = '▎',
              numhl = 'GitSignsDeleteNr',
              linehl = 'GitSignsDeleteLn',
            },
            changedelete = {
              hl = 'GitSignsChange',
              text = '▎',
              numhl = 'GitSignsChangeNr',
              linehl = 'GitSignsChangeLn',
            },
          },
          keymaps = {
            -- Default keymap options
            noremap = true,
            ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'" },
            ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'" },
            -- Text objects
            ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
            ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
          },
        }
      end,
    }

    -- Git diff/merge tool
    use {
      'sindrets/diffview.nvim',
      cmd = { 'DiffviewFileHistory', 'DiffviewOpen' },
      requires = { 'nvim-lua/plenary.nvim', opt = true },
      wants = 'plenary.nvim',
      config = function()
        require('diffview').setup {
          enhanced_diff_hl = false,
          hooks = {
            diff_buf_read = function(bufnr)
              vim.opt_local.winbar = '%f ' .. (not vim.bo.modifiable and '' or '')
            end,
            view_opened = function(view)
              vim.notify(('%s has opened on tab %d.'):format(view:class():name(), view.tabpage))
            end,
          },
          view = {
            merge_tool = {
              layout = 'diff3_mixed',
              disable_diagnostics = true,
            },
          },
        }
      end,
    }

    -- Indentation guides
    use {
      'lukas-reineke/indent-blankline.nvim',
      after = 'tokyonight.nvim',
      config = function()
        require('indent_blankline').setup {
          show_current_context = true,
          show_first_indent_level = false,
          show_trailing_blankline_indent = false,
        }
      end,
    }

    -- Tmux integration
    use {
      'christoomey/vim-tmux-navigator',
      cmd = {
        'TmuxNavigateLeft',
        'TmuxNavigateDown',
        'TmuxNavigateUp',
        'TmuxNavigateRight',
      },
      setup = function()
        map('n', '<m-h>', ':TmuxNavigateLeft<CR>')
        map('n', '<m-j>', ':TmuxNavigateDown<CR>')
        map('n', '<m-k>', ':TmuxNavigateUp<CR>')
        map('n', '<m-l>', ':TmuxNavigateRight<CR>')
      end,
      config = function()
        vim.g.tmux_navigator_no_mappings = true
      end,
    }

    -- File explorer
    use {
      'nvim-tree/nvim-tree.lua',
      cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
      setup = function()
        map('n', '\\', ':NvimTreeToggle<CR>')
      end,
      config = function()
        vim.cmd [[
          hi! NvimTreeCursorLine guibg=#292e42
          hi! NvimTreeGitIgnored guifg=#565f89
          hi! NvimTreeWinSeparator guibg=#24283b guifg=#24283b
        ]]

        local tree_cb = require('nvim-tree.config').nvim_tree_callback

        require('nvim-tree').setup {
          hijack_cursor = true, -- hijack the cursor in the tree to put it at the start of the filename
          filters = {
            custom = { '.DS_Store', '.git' },
          },
          git = {
            ignore = false,
          },
          renderer = {
            highlight_git = true,
            icons = {
              glyphs = {
                default = '',
                git = {
                  unstaged = '',
                  staged = '',
                  unmerged = '',
                  renamed = '➜',
                  untracked = '',
                  deleted = '',
                  ignored = '',
                },
                symlink = '',
              },
            },
            indent_markers = {
              enable = true,
            },
            root_folder_modifier = ':t',
          },
          update_focused_file = {
            enable = true, -- highlight current file
          },
          view = {
            hide_root_folder = true,
            mappings = {
              list = {
                -- NERDTree-like mappings
                { key = 'C', cb = tree_cb 'cd' },
                { key = 'u', cb = tree_cb 'dir_up' },
                { key = 'x', cb = tree_cb 'close_node' },
              },
            },
            width = 40,
          },
        }
      end,
    }

    -- Quickly comment code
    use { 'tpope/vim-commentary', keys = { 'gc' } }

    -- Turn quickfix buffer editable
    use { 'itchyny/vim-qfedit', event = 'CursorMoved' }

    -- GNU Readline emulation
    use {
      'linty-org/readline.nvim',
      event = { 'CmdlineEnter', 'CmdWinEnter', 'InsertEnter' },
      config = function()
        local readline = require 'readline'
        map('!', '<C-k>', readline.kill_line)
        map('!', '<C-u>', readline.backward_kill_line)
        map('!', '<M-d>', readline.kill_word)
        map('!', '<C-w>', readline.backward_kill_word)
        map('!', '<C-a>', readline.beginning_of_line)
        map('!', '<C-e>', readline.end_of_line)
        map('!', '<M-b>', readline.backward_word)
        map('!', '<M-f>', readline.forward_word)
        -- `map` does not work for the mappings below
        -- apparently the `silent` option breaks them
        vim.keymap.set('!', '<C-b>', '<Left>')
        vim.keymap.set('!', '<C-f>', '<Right>')
        vim.keymap.set('!', '<C-d>', '<Delete>')
        vim.keymap.set('!', '<C-h>', '<BS>')
      end,
    }

    -- Quickly surround with quotes/parens/etc
    use {
      'tpope/vim-surround',
      keys = { { 'n', 'cs' }, { 'n', 'ds' }, { 'n', 'ys' }, { 'v', 'S' } },
    }

    -- Documentation generator
    use {
      'danymat/neogen',
      cmd = 'Neogen',
      requires = 'nvim-treesitter/nvim-treesitter',
      tag = '*',
      config = function()
        require('neogen').setup {}
      end,
    }

    -- Statusline
    use {
      'nvim-lualine/lualine.nvim',
      after = 'tokyonight.nvim',
      config = function()
        require 'plugins.statusline'
      end,
    }

    -- Project configurations
    use {
      'tpope/vim-projectionist',
      config = function()
        map('n', '<leader>aa', ':A<CR>')
        map('n', '<leader>as', ':AS<CR>')
        map('n', '<leader>av', ':AV<CR>')

        require 'plugins.projections'
      end,
    }

    -- Actions with motions
    use {
      'obxhdx/vim-action-mapper',
      keys = { '<Leader>r', '<Leader>g' },
      config = function()
        function _G.find_and_replace(text, type)
          local visual_modes = { 'v', '^V' }
          local use_word_boundary = not contains(visual_modes, type)
          local pattern = use_word_boundary and '\\<' .. text .. '\\>' or text
          local new_text = vim.fn.input('Replace ' .. pattern .. ' with: ', text)

          if #new_text > 0 then
            exec_preserving_cursor_pos(',$s/' .. pattern .. '/' .. new_text .. '/gc')
          end
        end

        vim.cmd [[
          function! FindAndReplace(text, type)
            call v:lua.find_and_replace(a:text, a:type)
          endfunction
          autocmd User MapActions call MapAction('FindAndReplace', '<Leader>r')

          function! GrepWithMotion(text, type)
            execute("Grep '".trim(a:text)."'")
          endfunction
          autocmd User MapActions call MapAction('GrepWithMotion', '<Leader>g')

          doautocmd User MapActions
        ]]
      end,
    }

    -- Telescope
    use {
      'nvim-telescope/telescope.nvim',
      cmd = 'Telescope',
      keys = { '<leader>g' }, -- grep with motion
      requires = {
        { 'nvim-lua/plenary.nvim', opt = true },
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', opt = true },
        { 'nvim-telescope/telescope-live-grep-args.nvim', opt = true },
      },
      wants = {
        'plenary.nvim',
        'telescope-fzf-native.nvim',
        'telescope-live-grep-args.nvim',
        'vim-action-mapper',
      },
      setup = function()
        map('n', '<leader>fb', ':Telescope buffers<CR>')
        map('n', '<leader>fc', ':Telescope commands<CR>')
        map('n', '<leader>ff', ':Telescope find_files<CR>')
        map('n', '<leader>fg', ':Telescope live_grep_args<CR>')
        map('n', '<leader>fh', ':Telescope command_history<CR>')
        map('n', '<leader>fl', ':Telescope current_buffer_fuzzy_find<CR>')
        map('n', '<leader>fp', ':Telescope resume<CR>')
        map('n', '<leader>fr', ':Telescope oldfiles<CR>')
      end,
      config = function()
        require 'plugins.telescope'
      end,
    }

    -- Treesitter
    use {
      'nvim-treesitter/nvim-treesitter',
      event = { 'BufReadPre', 'BufNewFile' },
      run = ':TSUpdate',
      requires = {
        { 'JoosepAlviste/nvim-ts-context-commentstring', after = 'nvim-treesitter' },
        { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' },
      },
      config = function()
        vim.o.foldmethod = 'expr'
        vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
        vim.o.fillchars = 'fold: '
        vim.o.foldminlines = 1
        vim.o.foldnestmax = 3
        vim.o.foldtext = 'v:lua.custom_fold_text()'

        function custom_fold_text()
          local line_count = vim.v.foldend - vim.v.foldstart + 1
          local foldstart = vim.fn.getline(vim.v.foldstart):gsub('\t', ' ')

          if foldstart:find '^%s' ~= nil then
            -- line start with space, replace spaces with formatted text
            local offset = string.len(string.match(foldstart, '^%s+')) - 3 -- leading spaces minus icon and surrounding spaces
            local leading_text = string.format(' %s ', string.rep('-', offset))
            foldstart = foldstart:gsub('^%s+', leading_text) -- replace spaces with icon and dashes
          end

          return string.format('%s   (%s lines)', foldstart, line_count)
        end

        require('nvim-treesitter.configs').setup {
          ensure_installed = 'all',
          highlight = {
            enable = true,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
          },
          -- Context aware comments (nvim-ts-context-commentstring)
          context_commentstring = {
            enable = true,
          },
          -- Additional text ojbects (nvim-treesitter-textobjects)
          textobjects = {
            select = {
              enable = true,
              keymaps = {
                ['ib'] = '@block.inner',
                ['ab'] = '@block.outer',
                ['ic'] = '@call.inner',
                ['ac'] = '@call.outer',
                ['if'] = '@function.inner',
                ['af'] = '@function.outer',
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
      branch = 'release',
      config = function()
        require 'plugins.coc'
      end,
    }

    -- Emmet
    use {
      'mattn/emmet-vim',
      keys = { { 'i', '<C-y>,' } },
    }

    -- Highlight hex colors
    use {
      'norcalli/nvim-colorizer.lua',
      cmd = 'ColorizerToggle',
      config = function()
        require('colorizer').setup()
      end,
    }

    -- Incremental fuzzy search motion
    use {
      'rlane/pounce.nvim',
      cmd = { 'Pounce', 'PounceRepeat' },
      setup = function()
        map('n', 'gs', '<cmd>Pounce<CR>')
        map('n', 'gS', '<cmd>PounceRepeat<CR>')
        map('v', 'gs', '<cmd>Pounce<CR>')
        map('o', 'gs', '<cmd>Pounce<CR>')
      end,
      config = function()
        require('pounce').setup {}

        vim.cmd [[
        hi PounceGap cterm=none ctermfg=0 ctermbg=2 gui=none guifg=black guibg=#00aa00
        hi PounceMatch cterm=none ctermfg=0 ctermbg=10 gui=none guifg=black guibg=#11dd11
        ]]
      end,
    }

    -- Highlight some UI elements based on current mode
    use {
      'mvllow/modes.nvim',
      after = 'tokyonight.nvim',
      config = function()
        require('modes').setup {
          set_cursorline = false,
        }

        -- Highlight numbers fg only
        highlight('ModesCopyCursorLineNr', { fg = '#f5c359', bold = true })
        highlight('ModesInsertCursorLineNr', { fg = '#78ccc5', bold = true })
        highlight('ModesDeleteCursorLineNr', { fg = '#c75c6a', bold = true })
        highlight('ModesVisualCursorLineNr', { fg = '#9745be', bold = true })

        -- Don't highlight sign column
        highlight('ModesCopyCursorLineSign', { bg = 'none' })
        highlight('ModesInsertCursorLineSign', { bg = 'none' })
        highlight('ModesDeleteCursorLineSign', { bg = 'none' })
        highlight('ModesVisualCursorLineSign', { bg = 'none' })
      end,
    }

    -- Fancy notifications
    use {
      'rcarriga/nvim-notify',
      config = function()
        require('notify').setup {
          max_width = 50,
          stages = 'fade',
        }

        -- replace built-in `notify`
        vim.notify = require 'notify'
      end,
    }

    -- Bootstrap packer plugins
    if packer_bootstrap then
      require('packer').sync()
    end
  end,
  config = {
    auto_reload_compiled = false,
    snapshot_path = vim.fn.stdpath 'config',
  },
}
