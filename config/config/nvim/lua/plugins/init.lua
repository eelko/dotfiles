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
        vim.cmd 'color tokyonight'
        highlight('CurSearch', { bg = '#637ab3', fg = '#c0caf5' })
        highlight('Folded', { bg = '#24283b', fg = '#565f89' })
        highlight('NvimTreeFolderIcon', { bg = 'none', fg = '#8094b4' })
        highlight('TroubleNormal', { bg = '#24283b', fg = '#c0caf5' })
      end,
    }

    -- Tabline
    use {
      'akinsho/bufferline.nvim',
      after = 'tokyonight.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true },
      config = function()
        require('bufferline').setup {
          options = {
            diagnostics = 'nvim_lsp',
            ---@diagnostic disable-next-line: unused-local
            diagnostics_indicator = function(count, level, diagnostics_dict, context)
              local icon = level:match 'error' and ' ' or ' '
              return ' ' .. icon .. count
            end,
            max_name_length = 50,
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

        highlight('IndentBlanklineContextChar', { bg = 'none', fg = '#4e4e4e' })
      end,
    }

    -- Auto pairs
    use {
      'windwp/nvim-autopairs',
      after = 'nvim-cmp',
      config = function()
        require('nvim-autopairs').setup()
        -- inserts `()` after selecting a function or method item from completion menu
        local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
        require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done { map_char = { tex = '' } })
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
      'kyazdani42/nvim-tree.lua',
      cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
      requires = { 'kyazdani42/nvim-web-devicons', opt = true },
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

    -- Markdown previewer
    use { 'iamcco/markdown-preview.nvim', cmd = 'MarkdownPreview', run = ':call mkdp#util#install()' }

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
      requires = { { 'kyazdani42/nvim-web-devicons', opt = true } },
      config = function()
        require 'plugins.statusline_basic'
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
      requires = {
        { 'nvim-lua/plenary.nvim', opt = true },
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', opt = true },
      },
      wants = {
        'plenary.nvim',
        'telescope-fzf-native.nvim',
        'trouble.nvim',
        'vim-action-mapper',
      },
      setup = function()
        map('n', '<leader>fb', ':Telescope buffers<CR>')
        map('n', '<leader>fc', ':Telescope commands<CR>')
        map('n', '<leader>ff', ':Telescope find_files<CR>')
        map('n', '<leader>fg', ':Telescope live_grep<CR>')
        map('n', '<leader>fh', ':Telescope command_history<CR>')
        map('n', '<leader>fl', ':Telescope current_buffer_fuzzy_find<CR>')
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
          local foldstart = vim.fn.substitute(vim.fn.getline(vim.v.foldstart), '\t', ' ', 'g')
          local line_count = vim.v.foldend - vim.v.foldstart + 1
          local icon = ''
          local separator = '…'
          return string.format('%s %s %s (%s lines)', foldstart, separator, icon, line_count)
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
    local use_coc = vim.g.use_coc or false
    use {
      'neoclide/coc.nvim',
      disable = not use_coc,
      branch = 'release',
      requires = { 'fannheyward/telescope-coc.nvim', opt = true },
      config = function()
        require 'plugins.coc'
      end,
    }

    -- Snippets
    use {
      'hrsh7th/vim-vsnip',
      disable = use_coc,
      event = { 'CmdWinEnter', 'InsertEnter' },
      keys = { { 'n', 's' }, { 'x', 's' } },
      requires = {
        { 'hrsh7th/vim-vsnip-integ', opt = true },
      },
      config = function()
        vim.g.vsnip_filetypes = {
          javascript = { 'javascript', 'javascriptreact' },
          javascriptreact = { 'javascript', 'javascriptreact' },
          typescript = { 'javascript', 'javascriptreact' },
          typescriptreact = { 'javascript', 'javascriptreact' },
        }

        vim.g.vsnip_snippet_dir = vim.fn.stdpath 'config' .. '/snippets'

        -- Select use as $TM_SELECTED_TEXT in the next snippet
        map('n', 's', '<Plug>(vsnip-select-text)')
        map('x', 's', '<Plug>(vsnip-select-text)')
      end,
    }

    -- Code Completion
    use {
      'hrsh7th/nvim-cmp',
      event = { 'CmdlineEnter', 'CmdWinEnter', 'InsertEnter' },
      disable = use_coc,
      requires = {
        { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-vsnip', after = 'nvim-cmp' },
      },
      config = function()
        require 'plugins.completion'
      end,
    }

    -- Native LSP
    use {
      'neovim/nvim-lspconfig',
      disable = use_coc,
      event = { 'BufReadPre', 'BufNewFile' },
      requires = {
        -- Enhanced LSP experience for TS
        { 'jose-elias-alvarez/typescript.nvim', opt = true },
        -- JSON schema store integration
        { 'b0o/schemastore.nvim', opt = true },
        -- Completion integration
        { 'hrsh7th/cmp-nvim-lsp', opt = true },
        -- Code context
        { 'SmiteshP/nvim-navic', opt = true },
      },
      wants = {
        'cmp-nvim-lsp',
        'nvim-navic',
        'schemastore.nvim',
        'typescript.nvim',
      },
      config = function()
        require 'plugins.lsp'
      end,
    }

    -- Extract JSX components
    use {
      'napmn/react-extract.nvim',
      keys = '<Leader>e',
      requires = {
        'neovim/nvim-lspconfig',
        'nvim-treesitter/nvim-treesitter',
      },
      config = function()
        local react_extract = require 'react-extract'
        react_extract.setup()
        map('v', '<Leader>e', react_extract.extract_to_new_file)
      end,
    }

    -- Light bulb for LSP code actions
    use {
      'kosayoda/nvim-lightbulb',
      after = 'nvim-lspconfig',
      config = function()
        require('nvim-lightbulb').setup {
          sign = {
            enabled = false,
          },
          virtual_text = {
            enabled = true,
            hl_mode = 'combine',
            text = '',
          },
        }

        highlight('LightBulbVirtualText', { fg = 'lightyellow' })

        vim.cmd [[ au! CursorHold * lua require('nvim-lightbulb').update_lightbulb() ]]
      end,
    }

    -- Trouble
    use {
      'folke/trouble.nvim',
      cmd = { 'Grep', 'Trouble' },
      after = 'telescope.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true },
      setup = function()
        -- quickfix/loclist integration
        function OpenTrouble()
          local buftype = 'quickfix'

          if vim.fn.getloclist(0, { filewinid = 1 }).filewinid ~= 0 then
            buftype = 'loclist'
          end

          local ok, trouble = pcall(require, 'trouble')
          if ok and pcall(vim.api.nvim_win_close, 0, true) then
            trouble.toggle(buftype)
          else
            local set = vim.opt_local
            set.colorcolumn = ''
            set.number = false
            set.relativenumber = false
            set.signcolumn = 'no'
          end
        end
        vim.cmd [[ au! BufWinEnter quickfix silent :lua OpenTrouble() ]]
      end,
      config = function()
        require('trouble').setup {}
      end,
    }

    -- Emmet
    use {
      'mattn/emmet-vim',
      after = 'nvim-cmp',
      keys = { 'i', '<C-y>,' },
    }

    -- Highlight hex colors
    use {
      'norcalli/nvim-colorizer.lua',
      cmd = 'ColorizerToggle',
      config = function()
        require('colorizer').setup()
      end,
    }

    -- Fade inactive buffers
    use {
      'levouh/tint.nvim',
      after = 'tokyonight.nvim',
      config = function()
        require('tint').setup {
          focus_change_events = {
            focus = { 'FocusGained', 'WinEnter' },
            unfocus = { 'FocusLost', 'WinLeave' },
          },
          highlight_ignore_patterns = {
            'EndOfBuffer',
            'IndentBlankline.*',
            'LineNr',
            'NonText',
            'Trouble.*',
            'WinSeparator',
          },
          window_ignore_function = function(winid)
            local bufid = vim.api.nvim_win_get_buf(winid)
            local buftype = vim.api.nvim_buf_get_option(bufid, 'buftype')
            local filetype = vim.api.nvim_buf_get_option(bufid, 'filetype')
            local floating = vim.api.nvim_win_get_config(winid).relative ~= ''

            -- Do not tint `terminal`, floating windows, etc, tint everything else
            return buftype == 'terminal' or floating or filetype == 'NvimTree'
          end,
        }
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
        require('modes').setup()

        -- Highlight numbers fg only
        highlight('ModesCopyCursorLineNr', { fg = '#f5c359' })
        highlight('ModesInsertCursorLineNr', { fg = '#78ccc5' })
        highlight('ModesDeleteCursorLineNr', { fg = '#c75c6a' })
        highlight('ModesVisualCursorLineNr', { fg = '#9745be' })

        -- Don't highlight sign column
        highlight('ModesCopyCursorLineSign', { bg = 'none' })
        highlight('ModesInsertCursorLineSign', { bg = 'none' })
        highlight('ModesDeleteCursorLineSign', { bg = 'none' })
        highlight('ModesVisualCursorLineSign', { bg = 'none' })
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
