return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
    'nvim-treesitter/nvim-treesitter-context',
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  event = { 'BufNewFile', 'BufReadPre' },
  build = ':TSUpdate',
  config = function()
    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    vim.o.foldcolumn = 'auto'
    vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.o.foldlevel = 99
    vim.o.foldmethod = 'expr'
    vim.o.foldminlines = 1
    vim.o.foldnestmax = 3
    vim.o.foldtext = 'v:lua.custom_fold_text()'

    function custom_fold_text()
      local line_count = vim.v.foldend - vim.v.foldstart + 1
      local foldstart = vim.fn.getline(vim.v.foldstart):gsub('\t', ' ')
      return string.format('%s  󰦸 (%s lines)', foldstart, line_count)
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
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<M-space>',
        },
      },
      indent = {
        enable = true,
      },

      -- nvim-ts-context-commentstring
      context_commentstring = {
        enable = true,
      },

      -- vim-matchup
      matchup = {
        enable = true,
      },

      -- nvim-treesitter/nvim-treesitter-textobjects
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            ['ib'] = '@block.inner',
            ['ab'] = '@block.outer',
            ['ii'] = '@call.inner',
            ['ai'] = '@call.outer',
            -- ['ac'] = '@comment.outer',
            ['ic'] = '@conditional.inner',
            ['ac'] = '@conditional.outer',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['il'] = '@loop.inner',
            ['al'] = '@loop.outer',
            ['ia'] = '@parameter.inner',
            ['aa'] = '@parameter.outer',
          },
        },
      },
    }
  end,
}
