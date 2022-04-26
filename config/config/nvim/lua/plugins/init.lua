require 'utils'

-- Bootstrap packer
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

-- Regenerate compiled loader file whenever this file is updated
vim.cmd [[
  augroup PackerUserConfig
    autocmd!
    autocmd BufWritePost */nvim/lua/*.lua source <afile> | PackerCompile
  augroup end
]]

-- Declare plugins
return require('packer').startup(function(use)
  -- Let Packer manage itself
  use { 'wbthomason/packer.nvim' }

  -- Improve startup time
  use { 'lewis6991/impatient.nvim' }

  -- Colors
  use {
    'folke/tokyonight.nvim',
    after = 'nvim-treesitter',
    config = function()
      vim.cmd 'color tokyonight'
      highlight('Folded', '#24283b', '#565f89')
      highlight('Search', '#ff9e64', 'black')
      highlight('VertSplit', '#24283b', '#080808')
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
            {
              filetype = 'neo-tree',
              text = 'Files',
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
          topdelete = { hl = 'GitSignsDelete', text = '▎', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
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

      highlight('IndentBlanklineContextChar', 'none', '#4e4e4e')
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
    'nvim-neo-tree/neo-tree.nvim',
    cmd = 'Neotree',
    branch = 'v2.x',
    requires = {
      { 'nvim-lua/plenary.nvim', opt = true },
      { 'kyazdani42/nvim-web-devicons', opt = true },
      { 'MunifTanjim/nui.nvim', opt = true },
    },
    wants = { 'nui.nvim' },
    setup = function()
      map('n', '\\', ':Neotree reveal<CR>')
    end,
    config = function()
      vim.g.neo_tree_remove_legacy_commands = 1

      vim.cmd 'hi NeoTreeNormal guifg=#a9b1d6 guibg=#1f2335'
      vim.cmd 'hi NeoTreeVertSplit guibg=#1D202F guifg=#1D202F'

      require('neo-tree').setup {
        enable_diagnostics = false,
        event_handlers = {
          {
            event = 'file_opened',
            handler = function(file_path)
              require('neo-tree').close_all()
            end,
          },
          {
            event = 'vim_buffer_enter',
            handler = function(arg)
              if vim.bo.filetype == 'neo-tree' then
                vim.cmd [[setlocal signcolumn=no]]
              end
            end,
          },
        },
        filesystem = {
          commands = {
            system_open = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.api.nvim_command('silent !open ' .. path)
            end,
          },
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = true,
            hide_by_name = {},
            never_show = {
              '.DS_Store',
              '.git',
            },
          },
          follow_current_file = true,
          use_libuv_file_watcher = true,
          window = {
            mappings = {
              ['\\'] = 'close_window',
              ['o'] = 'system_open',
            },
          },
        },
      }
    end,
  }

  use {
    'kyazdani42/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    setup = function()
      map('n', '<leader>nf', ':NvimTreeFindFile<CR>')
      map('n', '<leader>nt', ':NvimTreeToggle<CR>')
    end,
    config = function()
      vim.g.nvim_tree_git_hl = 0
      vim.g.nvim_tree_icons = { default = '', symlink = '' }
      vim.g.nvim_tree_show_icons = { git = 0, folders = 1, files = 1 }
      vim.g.nvim_tree_root_folder_modifier = ':t'

      vim.cmd 'hi NvimTreeVertSplit guibg=#1D202F guifg=#1D202F'

      local tree_cb = require('nvim-tree.config').nvim_tree_callback

      require('nvim-tree').setup {
        hijack_cursor = true, -- hijack the cursor in the tree to put it at the start of the filename
        update_focused_file = {
          enable = true, -- highlight current file
        },
        filters = {
          custom = { '.git' },
        },
        renderer = {
          indent_markers = {
            enable = true,
          },
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
  use { 'tpope/vim-rsi', event = { 'CmdlineEnter', 'CmdWinEnter', 'InsertEnter' } } -- insert mode
  use { 'ryvnf/readline.vim', after = 'vim-rsi' } -- command mode

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
    event = 'VimEnter',
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
      ]]
    end,
  }

  -- Easily add debug messages
  use {
    'obxhdx/vim-debug-logger',
    after = 'vim-action-mapper',
    requires = 'obxhdx/vim-action-mapper',
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    requires = {
      { 'nvim-lua/plenary.nvim', opt = true },
      { 'gbrlsnchs/telescope-lsp-handlers.nvim', opt = true },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', opt = true },
    },
    wants = {
      'telescope-lsp-handlers.nvim',
      'telescope-fzf-native.nvim',
    },
    setup = function()
      map('n', '<leader>fb', ':Telescope buffers<CR>', { noremap = true })
      map('n', '<leader>fc', ':Telescope commands<CR>', { noremap = true })
      map('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true })
      map('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true })
      map('n', '<leader>fh', ':Telescope command_history<CR>', { noremap = true })
      map('n', '<leader>fl', ':Telescope current_buffer_fuzzy_find<CR>', { noremap = true })
      map('n', '<leader>fr', ':Telescope oldfiles<CR>', { noremap = true })
    end,
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'

      telescope.setup {
        defaults = {
          file_ignore_patterns = { 'node_modules', '.git' },
          layout_strategy = 'vertical',
          mappings = {
            i = {
              ['<esc>'] = actions.close,
            },
          },
        },
        extensions = {
          lsp_handlers = {
            code_action = {
              telescope = require('telescope.themes').get_cursor {},
            },
          },
        },
        pickers = {
          current_buffer_fuzzy_find = {
            sorting_strategy = 'ascending',
          },
          find_files = {
            hidden = true,
          },
        },
      }

      telescope.load_extension 'fzf'
      telescope.load_extension 'lsp_handlers'

      vim.cmd [[
        function! GrepWithMotion(text, type)
          execute('lua require("telescope.builtin").grep_string({search = "'.trim(a:text).'"})')
        endfunction
      ]]
    end,
  }

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    event = 'UIEnter',
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
    opt = not use_coc,
    branch = 'release',
    requires = { 'fannheyward/telescope-coc.nvim', opt = true },
    config = function()
      require 'plugins.coc'
    end,
  }

  -- Snippets
  use {
    'hrsh7th/vim-vsnip',
    opt = use_coc,
    event = { 'CmdWinEnter', 'InsertEnter' },
    requires = {
      { 'hrsh7th/vim-vsnip-integ', opt = true },
    },
    config = function()
      vim.g.vsnip_filetypes = {
        javascriptreact = { 'javascript', 'typescriptreact' },
        typescript = { 'javascript' },
        typescriptreact = { 'javascript', 'typescriptreact' },
      }

      vim.g.vsnip_snippet_dir = vim.fn.stdpath 'config' .. '/snippets'
    end,
  }

  -- Code Completion
  use {
    'hrsh7th/nvim-cmp',
    event = { 'CmdlineEnter', 'CmdWinEnter', 'InsertEnter' },
    opt = use_coc,
    requires = {
      { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-vsnip', after = 'nvim-cmp' },
      { 'onsails/lspkind-nvim', opt = true },
    },
    wants = {
      'lspkind-nvim',
    },
    config = function()
      require 'plugins.completion'
    end,
  }

  -- Native LSP
  use {
    'neovim/nvim-lspconfig',
    opt = use_coc,
    requires = {
      -- Enhanced LSP experience for TS
      { 'jose-elias-alvarez/nvim-lsp-ts-utils', requires = { 'nvim-lua/plenary.nvim', opt = true } },
      -- JSON schema store integration
      { 'b0o/schemastore.nvim' },
      -- Completion integration
      { 'hrsh7th/cmp-nvim-lsp' },
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
    event = 'CursorMoved',
    config = function()
      require('nvim-lightbulb').setup {
        sign = {
          enabled = false,
        },
        virtual_text = {
          enabled = true,
          hl_mode = 'combine',
        },
      }

      vim.cmd [[
        autocmd! CursorMoved * lua require('nvim-lightbulb').update_lightbulb()
      ]]
    end,
  }

  -- Fade inactive buffers
  use {
    'TaDaa/vimade',
    event = { 'BufLeave', 'FocusLost' },
    config = function()
      vim.g.vimade = {
        enablefocusfading = 1,
        enabletreesitter = 1,
      }

      vim.cmd [[
        au! FileType NvimTree,neo-tree VimadeBufDisable
        au! FocusLost * VimadeFadeActive
        au! FocusGained * VimadeUnfadeActive
        au! InsertEnter * VimadeWinDisable
        au! InsertLeave * VimadeWinEnable
      ]]
    end,
  }

  -- Incremental fuzzy search motion
  use {
    'rlane/pounce.nvim',
    cmd = { 'Pounce', 'PounceRepeat' },
    setup = function()
      map('n', 's', '<cmd>Pounce<CR>')
      map('n', 'S', '<cmd>PounceRepeat<CR>')
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
    config = function()
      require('modes').setup {
        colors = {
          copy = '#e0af68',
          delete = '#c75c6a',
          insert = '#9ece6a',
          visual = '#7aa2f7',
        },
      }
    end,
  }

  -- Fix CursorHold performance
  -- Reference: https://github.com/neovim/neovim/issues/12587
  use {
    'antoinemadec/FixCursorHold.nvim',
    event = 'UIEnter',
    config = function()
      -- in millisecond, used for both CursorHold and CursorHoldI,
      -- use updatetime instead if not defined
      vim.g.cursorhold_updatetime = 500
    end,
  }

  -- GitHub copilot
  -- use { 'github/copilot.vim' } -- Only required for initial setup
  use {
    'zbirenbaum/copilot.lua',
    after = 'nvim-cmp',
    config = function()
      vim.defer_fn(function()
        require('copilot').setup()
      end, 100)
    end,
  }
  use {
    'zbirenbaum/copilot-cmp',
    after = { 'copilot.lua' },
  }

  -- Bootstrap packer plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
