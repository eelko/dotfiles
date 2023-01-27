return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  event = { 'BufNewFile', 'BufReadPre' },
  build = ':TSUpdate',
  config = function()
    vim.o.fillchars = 'fold: '
    vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.o.foldlevel = 99
    vim.o.foldmethod = 'expr'
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

      -- nvim-ts-context-commentstring
      context_commentstring = {
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
