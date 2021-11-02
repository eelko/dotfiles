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
    'folke/tokyonight.nvim',
    config = function()
      vim.cmd 'color tokyonight'
    end,
  }

  -- Tabline
  use {
    'akinsho/bufferline.nvim',
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

  -- -- Language pack
  -- use {
  --   'sheerun/vim-polyglot',
  --   config = function()
  --     vim.g.vim_markdown_conceal = false
  --     vim.g.vim_markdown_conceal_code_blocks = false
  --   end,
  -- }

  -- Git sings on gutter
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { hl = 'GitSignsAdd', text = '│', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
          change = { hl = 'GitSignsChange', text = '│', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
          delete = { hl = 'GitSignsDelete', text = '│', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
          topdelete = { hl = 'GitSignsDelete', text = '│', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
          changedelete = {
            hl = 'GitSignsChange',
            text = '│',
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
    'yggdroot/indentLine',
    config = function()
      vim.g.indentLine_faster = 1
      vim.g.indentLine_char = '│'
      vim.g.indentLine_fileTypeExclude = {
        'gitcommit',
        'help',
        'lsp-installer',
        'NvimTree',
        'packer',
        'TelescopePrompt',
        'TelescopeResults',
        'which_key',
      }
    end,
  }

  -- Auto pairs
  use {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
  }

  -- Tmux integration
  use {
    'christoomey/vim-tmux-navigator',
    config = function()
      vim.g.tmux_navigator_no_mappings = true
      map('n', '<m-h>', ':TmuxNavigateLeft<CR>')
      map('n', '<m-j>', ':TmuxNavigateDown<CR>')
      map('n', '<m-k>', ':TmuxNavigateUp<CR>')
      map('n', '<m-l>', ':TmuxNavigateRight<CR>')
    end,
  }

  -- File explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function()
      vim.g.nvim_tree_git_hl = 0
      vim.g.nvim_tree_icons = { default = '', symlink = '' }
      vim.g.nvim_tree_indent_markers = 1
      vim.g.nvim_tree_show_icons = { git = 0, folders = 1, files = 1 }
      vim.g.nvim_tree_root_folder_modifier = ':t'

      map('n', '<leader>nf', ':NvimTreeFindFile<CR>')
      map('n', '<leader>nt', ':NvimTreeToggle<CR>')

      cmd 'hi NvimTreeVertSplit guibg=#1D202F guifg=#1D202F'

      local tree_cb = require('nvim-tree.config').nvim_tree_callback

      require('nvim-tree').setup {
        hijack_cursor = true, -- hijack the cursor in the tree to put it at the start of the filename
        update_focused_file = {
          enable = true, -- highlight current file
        },
        filters = {
          custom = { '.git' },
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
  use { 'tpope/vim-commentary' }

  -- Turn quickfix buffer editable
  use { 'itchyny/vim-qfedit' }

  -- GNU Readline emulation
  use { 'tpope/vim-rsi', event = 'VimEnter' } -- insert mode
  use { 'ryvnf/readline.vim', after = 'vim-rsi' } -- command mode

  -- Quickly surround with quotes/parens/etc
  use { 'tpope/vim-surround', requires = { 'tpope/vim-repeat' } }

  -- Markdown previewer
  use { 'iamcco/markdown-preview.nvim', run = ':call mkdp#util#install()' }

  -- Documentation generator
  use {
    'kkoomen/vim-doge',
    run = ':call doge#install()',
    config = function()
      vim.g.doge_enable_mappings = 0
    end,
  }

  -- Statusline
  use {
    'nvim-lualine/lualine.nvim',
    requires = { { 'kyazdani42/nvim-web-devicons', opt = true } },
    config = function()
      local config = require 'tokyonight.config'
      local colors = require('tokyonight.colors').setup(config)
      local custom_theme = require 'lualine.themes.tokyonight'

      custom_theme.command = {
        a = { bg = colors.magenta, fg = colors.black },
        b = { bg = colors.fg_gutter, fg = colors.magenta },
      }

      custom_theme.visual = {
        a = { bg = colors.yellow, fg = colors.black },
        b = { bg = colors.fg_gutter, fg = colors.yellow },
      }

      local function active_lsp_clients()
        local buffer_filetype = vim.api.nvim_buf_get_option(0, 'filetype')
        local active_clients = vim.lsp.get_active_clients()

        if #active_clients == 0 then
          return ''
        end

        local clients = {}

        for _, client in ipairs(active_clients) do
          local filetypes = client.config.filetypes

          if filetypes and vim.fn.index(filetypes, buffer_filetype) ~= -1 then
            if not contains(clients, client.name) then
              table.insert(clients, client.name)
            end
          end
        end

        if #clients == 0 then
          return ''
        else
          local icon = ''
          return icon .. ' ' .. table.concat(clients, ' ')
        end
      end

      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = custom_theme,
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = { 'NvimTree' },
          always_divide_middle = true,
        },
        sections = {
          lualine_a = {
            {
              'mode',
              padding = 2,
              fmt = function()
                local mode_icons = {
                  ['n'] = 'N',
                  ['i'] = '',
                  ['v'] = '',
                  ['V'] = '',
                  [''] = '',
                  ['c'] = '',
                  ['t'] = '',
                  ['!'] = '',
                  ['r'] = '﯒',
                  ['r?'] = '',
                  ['R'] = '',
                }
                return mode_icons[vim.fn.mode()]
              end,
            },
          },
          lualine_b = {
            { 'filename', symbols = { modified = '  ', readonly = '  ' } },
          },
          lualine_c = {
            { 'branch', icon = '' },
            { active_lsp_clients },
            { 'diagnostics', sources = { 'nvim_lsp', 'coc' } },
          },
          lualine_x = {},
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = {},
      }
    end,
  }

  -- Faster text navigation
  use {
    'justinmk/vim-sneak',
    config = function()
      vim.g['sneak#label'] = 1
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
  }

  -- Keymap helper
  use {
    'liuchengxu/vim-which-key',
    config = function()
      vim.g.which_key_centered = 0

      vim.g.which_key_map = {
        d = 'Close current buffer',
        g = 'Grep operator',
        gg = 'which_key_ignore',
        l = 'Debug log operator',
        ll = 'which_key_ignore',
        p = 'Paste from clipboard after cursor',
        P = 'Paste from clipboard before cursor',
        q = 'Quit',
        r = 'Find/replace operator',
        rr = 'which_key_ignore',
        w = 'Save current buffer',
        x = 'Save current buffer and quit',
        y = 'Copy to clipboard',
        Y = 'Copy whole line to clipboard',
        a = {
          name = '+alternate',
          a = 'Open alternate file',
          s = 'Open alternate file in vertical split',
          v = 'Open alternate file in horizontal split',
        },
        c = {
          name = '+code',
          a = 'Show code actions',
          d = 'Go to definition',
          D = 'Go to declaration',
          i = 'Go to implementation',
          I = 'Add all missing imports',
          n = 'Show references',
          o = 'Organize imports',
          r = 'Rename symbol',
          R = 'Rename file',
          t = 'Go to type definition',
        },
        e = {
          name = '+diagnostics',
          e = 'Document diagnostics',
          w = 'Workspace diagnostics',
        },
        f = {
          name = '+find',
          b = 'Find open buffer',
          c = 'Find command',
          f = 'Find file',
          g = 'Live grep',
          h = 'Show recent commands',
          l = 'Filter lines in current buffer',
          r = 'Open recently edited file',
        },
        n = {
          name = '+navigate',
          f = 'Show current file in file explorer',
          t = 'Toggle file explorer',
        },
      }

      vim.fn['which_key#register']('<Space>', 'g:which_key_map')

      map('n', '<leader>', ":WhichKey '<Space>'<CR>")
      map('v', '<leader>', ":<c-u>WhichKeyVisual '<Space>'<CR>")
    end,
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'gbrlsnchs/telescope-lsp-handlers.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    },
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'

      telescope.setup {
        defaults = {
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
        },
      }

      telescope.load_extension 'fzf'
      telescope.load_extension 'lsp_handlers'

      map('n', '<leader>fb', ':Telescope buffers<CR>', { noremap = true })
      map('n', '<leader>fc', ':Telescope commands<CR>', { noremap = true })
      map('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true })
      map('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true })
      map('n', '<leader>fh', ':Telescope command_history<CR>', { noremap = true })
      map('n', '<leader>fl', ':Telescope current_buffer_fuzzy_find<CR>', { noremap = true })
      map('n', '<leader>fr', ':Telescope oldfiles<CR>', { noremap = true })
      map('n', '<leader>fs', ':Telescope lsp_dynamic_workspace_symbols<CR>', { noremap = true })
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
      vim.w.foldmethod = 'expr'
      vim.w.foldexpr = 'nvim_treesitter#foldexpr()'

      require('nvim-treesitter.configs').setup {
        ensure_installed = 'maintained',
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
        -- Better code navigation (nvim-treesitter-refactor)
        refactor = {
          highlight_definitions = { enable = true },
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
          'hrsh7th/cmp-cmdline',
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
