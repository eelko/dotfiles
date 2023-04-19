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

    local utils = require 'utils'
    local flash = utils.flash
    local map = utils.map

    --- Navigate between functions, Jest tests or describe blocks.
    -- This function is meant to be used with a keybinding to quickly jump
    -- between different code blocks in a JavaScript or TypeScript file.
    -- @param direction (string) Direction of navigation, 'next' or 'previous'.
    -- @param block_type (string) Type of block to navigate, 'test' or 'describe'.
    function navigate_js(direction, block_type)
      -- Import necessary Tree-sitter modules
      local ts_utils = require 'nvim-treesitter.ts_utils'
      local parsers = require 'nvim-treesitter.parsers'

      -- Get current buffer and language
      local bufnr = vim.api.nvim_get_current_buf()
      local lang = parsers.get_buf_lang(bufnr)

      -- Get parser and parse buffer to get syntax tree
      local parser = parsers.get_parser(bufnr, lang)
      local tree = parser:parse()[1]

      -- Define query text based on block_type and parse the query
      local query_text
      if block_type == 'test' then
        query_text = '(call_expression (identifier) @test_name (#match? @test_name "^(test|it)$"))'
      elseif block_type == 'describe' then
        query_text = '(call_expression (identifier) @describe (#match? @describe "^describe$"))'
      elseif block_type == 'function' then
        query_text = [[
          (function_declaration name: (identifier) @function_name)
          (variable_declarator (identifier) @function_name (arrow_function))
        ]]
      end
      local tst_query = vim.treesitter.query.parse(lang, query_text)

      -- Initialize node variables
      local next_node = nil
      local first_node = nil
      local last_node = nil

      -- Get syntax node at cursor position
      local current_node = ts_utils.get_node_at_cursor()

      --- Determine if node1 is before node2 in the buffer.
      -- @param node1 (node) The first syntax node.
      -- @param node2 (node) The second syntax node.
      -- @return (bool) True if node1 is before node2, False otherwise.
      local function node_is_before(node1, node2)
        local row1, col1 = node1:start()
        local row2, col2 = node2:start()
        return row1 < row2 or (row1 == row2 and col1 < col2)
      end

      -- Iterate through all nodes matched by the query
      for _, node, metadata in tst_query:iter_captures(tree:root(), bufnr) do
        -- Update first and last nodes
        if not first_node or node_is_before(node, first_node) then
          first_node = node
        end

        if not last_node or node_is_before(last_node, node) then
          last_node = node
        end

        -- Find the next_node depending on the direction
        if direction == 'next' and node_is_before(current_node, node) then
          if not next_node or node_is_before(node, next_node) then
            next_node = node
          end
        elseif direction == 'previous' and node_is_before(node, current_node) then
          if not next_node or node_is_before(next_node, node) then
            next_node = node
          end
        end
      end

      -- If no next_node is found, wrap around to the first or last node
      if not next_node then
        if direction == 'next' then
          next_node = first_node
        elseif direction == 'previous' then
          next_node = last_node
        end
      end

      -- Set cursor position to the next_node's starting position
      if next_node then
        local start_row, _, end_row, _ = next_node:range()
        ts_utils.goto_node(next_node)

        -- Briefly flash the current line
        flash(start_row, end_row)

        -- Center buffer
        vim.cmd 'normal zz'
      end
    end

    vim.api.nvim_create_augroup('TreeSitterGroup', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = 'TreeSitterGroup',
      pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
      callback = function()
        local function add_map(key, direction, scope)
          map('n', key, function()
            navigate_js(direction, scope)
          end, { desc = string.format('[TreeSitter] Jump to %s %s', direction, scope) })
        end

        -- Jump between function definitions
        add_map(']f', 'next', 'function')
        add_map('[f', 'previous', 'function')

        -- Jump between test blocks
        add_map(']t', 'next', 'test')
        add_map('[t', 'previous', 'test')

        -- Jump between describe blocks
        add_map(']T', 'next', 'describe')
        add_map('[T', 'previous', 'describe')
      end,
      desc = '[TreeSitter] Create mappings for easier JavaScript navigation',
    })
  end,
}
