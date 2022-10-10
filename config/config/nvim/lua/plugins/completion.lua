require 'utils'

highlight('CmpGhostText', { fg = '#565f89' })

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local kind_icons = {
  Text = '',
  Method = '',
  Function = '',
  Constructor = '⌘',
  Field = 'ﰠ',
  Variable = '',
  Class = 'ﴯ',
  Interface = '',
  Module = '',
  Property = 'ﰠ',
  Unit = '塞',
  Value = '',
  Enum = '',
  Keyword = '廓',
  Snippet = '',
  Color = '',
  File = '',
  Reference = '',
  Folder = '',
  EnumMember = '',
  Constant = '',
  Struct = 'פּ',
  Event = '',
  Operator = '',
  TypeParameter = '',
}

local cmp = require 'cmp'

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },

  experimental = {
    ghost_text = { hl_group = 'CmpGhostText' },
  },

  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, vim_item)
      local item_kind = vim_item.kind == 'Text' and 'Buffer' or vim_item.kind
      local item_source = ({
        buffer = '',
        nvim_lsp = '',
        vsnip = '',
      })[entry.source.name]

      vim_item.menu = string.format('%11s %s', item_kind, item_source or '')
      vim_item.kind = kind_icons[vim_item.kind]

      return vim_item
    end,
  },

  mapping = cmp.mapping.preset.insert {
    ['<C-e>'] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },

    ['<CR>'] = cmp.mapping.confirm { select = true },

    ['<Tab>'] = cmp.mapping {
      c = function(fallback)
        if cmp.visible() then
          cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
        else
          fallback()
        end
      end,
      i = function(fallback)
        if vim.fn['vsnip#available']() == 1 then
          feedkey('<Plug>(vsnip-expand-or-jump)', '')
        elseif cmp.visible() then
          cmp.confirm()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback() -- The fallback function sends an already mapped key. In this case, it's probably `<Tab>`.
        end
      end,
      s = function(fallback)
        if vim.fn['vsnip#available']() == 1 then
          feedkey('<Plug>(vsnip-expand-or-jump)', '')
        else
          fallback() -- The fallback function sends an already mapped key. In this case, it's probably `<Tab>`.
        end
      end,
    },

    ['<S-Tab>'] = cmp.mapping(function()
      if vim.fn['vsnip#jumpable'](-1) == 1 then
        feedkey('<Plug>(vsnip-jump-prev)', '')
      end
    end, {
      'i',
      's',
    }),
  },

  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },

  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
}

local cmdline_overrides = cmp.mapping.preset.cmdline {
  ['<Tab>'] = {
    c = function()
      if cmp.visible() then
        cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
      else
        cmp.complete()
      end
    end,
  },
  ['<S-Tab>'] = function() end,
}

-- Use buffer source for '/'
cmp.setup.cmdline('/', {
  mapping = cmdline_overrides,
  sources = {
    { name = 'buffer' },
  },
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  mapping = cmdline_overrides,
  sources = cmp.config.sources {
    { name = 'cmdline' },
    { name = 'path' },
  },
})
