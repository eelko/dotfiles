local cmd = vim.cmd
local exec = vim.api.nvim_exec
local fn = vim.fn
local scopes = {o = vim.o, b = vim.bo, g = vim.g, w = vim.wo}

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function opt(scope, key, value)
  scopes[scope][key] = value
end

local install_path = fn.stdpath('data')..'/site/pack/packer/opt/paq-nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  cmd('!git clone https://github.com/savq/paq-nvim.git '..install_path)
  cmd 'packadd paq-nvim'
end

cmd 'packadd paq-nvim'
local paq = require('paq-nvim').paq
paq { 'savq/paq-nvim', opt = true } -- Let Paq manage itself

-- Colors
paq 'sjl/badwolf'
cmd 'colorscheme badwolf'
exec([[
function! SanitizeColors()
  hi CursorLine guibg=#444444
  hi LineNr guibg=NONE
  hi MatchParen guibg=NONE
  hi Normal guibg=NONE
  hi Pmenu guifg=#f8f6f2 guibg=#484A55
  hi PmenuSbar guibg=#2B2C31
  hi PmenuThumb guibg=grey
  hi SignColumn guibg=NONE
  hi StatusLineNC gui=bold guifg=gray guibg=#262626
  hi VertSplit guifg=#3a3a3a guibg=#3a3a3a
  hi Visual guibg=#626262
  hi! link ColorColumn CursorLine

  hi VertSplit guibg=#262626 guifg=#262626
  hi NormalNC guibg=#3a3a3a

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
]], false)

-- Tabs
paq 'ap/vim-buftabline'
opt('g', 'buftabline_show', true)
opt('g', 'buftabline_indicators', true)
exec([[
  hi BufTabLineCurrent gui=bold guibg=#ff5f5f guifg=#080808
  hi BufTabLineActive  gui=bold guibg=#3a3a3a guifg=#ff5f5f
  hi BufTabLineHidden  gui=bold guibg=#3a3a3a guifg=#D5C4A1
  hi BufTabLineFill    gui=bold guibg=#3a3a3a guifg=#D5C4A1
]], false)

-- Language Pack
paq 'sheerun/vim-polyglot'
opt('g', 'vim_markdown_conceal', true)
opt('g', 'vim_markdown_conceal_code_blocks', false)

-- Git Gutter
paq 'mhinz/vim-signify'
opt('g', 'signify_sign_show_count', false)
opt('g', 'signify_priority', 5)
opt('g', 'signify_sign_add', '│')
opt('g', 'signify_sign_delete', '│')
opt('g', 'signify_sign_delete_first_line', '│')
opt('g', 'signify_sign_change', '│')
opt('g', 'signify_sign_changedelete', '│')
exec([[
  hi SignifySignAdd    guifg=#9BB76D guibg=NONE
  hi SignifySignChange guifg=#00AFFF guibg=NONE
  hi SignifySignDelete guifg=#FF5F5F guibg=NONE
]], false)

-- Indentation Guides
paq 'yggdroot/indentLine'
opt('g', 'indentLine_faster', 1)
opt('g', 'indentLine_char', '┊')

-- Auto Pairs
paq 'tmsvg/pear-tree'
opt('g', 'pear_tree_repeatable_expand', false)

-- Tmux Integration
paq 'christoomey/vim-tmux-navigator'
opt('g', 'tmux_navigator_no_mappings', true)
map('n', '<m-h>', ':TmuxNavigateLeft<CR>')
map('n', '<m-j>', ':TmuxNavigateDown<CR>')
map('n', '<m-k>', ':TmuxNavigateUp<CR>')
map('n', '<m-l>', ':TmuxNavigateRight<CR>')

-- File Explorer
paq 'kyazdani42/nvim-web-devicons'
paq 'kyazdani42/nvim-tree.lua'
opt('g', 'nvim_tree_bindings', { close_node={'x'} })
opt('g', 'nvim_tree_follow', 1)
opt('g', 'nvim_tree_git_hl', 0)
opt('g', 'nvim_tree_icons', { default='', symlink='' })
opt('g', 'nvim_tree_ignore', { '.git' })
opt('g', 'nvim_tree_indent_markers', 1)
opt('g', 'nvim_tree_show_icons', { git=0, folders=1, files=1 })
map('n', '<leader>nf', ':NvimTreeFindFile<CR>')
map('n', '<leader>nt', ':NvimTreeToggle<CR>')

-- Toggle Comments
paq 'tpope/vim-commentary'

-- Misc
paq 'itchyny/vim-qfedit' -- Turn quickfix buffer editable
paq 'tpope/vim-rsi' -- Readline keymaps for command bar
paq 'tpope/vim-surround'

paq 'tpope/vim-projectionist'
map('n', '<leader>aa', ':A<CR>')
map('n', '<leader>as', ':AS<CR>')
map('n', '<leader>av', ':AV<CR>')

paq('obxhdx/vim-action-mapper')
exec([[
function! FindAndReplace(text, type)
 let l:use_word_boundary = index(['v', '^V'], a:type) < 0
 let l:pattern = l:use_word_boundary ? '<'.a:text.'>' : a:text
 let l:new_text = input('Replace '.l:pattern.' with: ', a:text)

 if len(l:new_text)
   call SaveCursorPos(',$s/\v'.l:pattern.'/'.l:new_text.'/gc')
 endif
endfunction

autocmd User MapActions call MapAction('FindAndReplace', '<Leader>r')

function! DebugLog(text, ...)
 let javascript_template = "console.log('==> %s:', %s);"
 let supported_languages = { 'java': 'System.out.println("==> %s: " + %s);', 'javascript': javascript_template, 'javascript.jsx': j→
 let log_expression = get(supported_languages, &ft, '')

 if empty(log_expression)
   echohl ErrorMsg | echo 'DebugLog: filetype "'.&ft.'" not suppported.' | echohl None
   return
 endif

 execute "normal o".printf(log_expression, a:text, a:text)
endfunction

autocmd User MapActions call MapAction('DebugLog', '<leader>l')

function! GrepWithMotion(text, type) "{{{
 execute('Grep '.a:text)
endfunction

autocmd User MapActions call MapAction('GrepWithMotion', '<Leader>g')
]], false)

-- FZF
paq {'junegunn/fzf', hook='fzf#install()'}
paq 'junegunn/fzf.vim'
opt('g', 'fzf_layout', { window = { width = 0.7, height = 0.4 } })
opt('g', 'projectionist_ignore_term', 1)
map('n', '<leader>fb', ':Buffers<CR>')
map('n', '<leader>fc', ':Commands<CR>')
map('n', '<leader>ff', ':Files<CR>')
map('n', '<leader>fh', ':History:<CR>')
map('n', '<leader>fl', ':BLines<CR>')
map('n', '<leader>fr', ':History<CR>')

-- Treesitter
paq {'nvim-treesitter/nvim-treesitter', hook=':TSUpdate'}
paq 'nvim-treesitter/nvim-treesitter-textobjects'
paq 'nvim-treesitter/nvim-treesitter-refactor'

opt('w', 'foldmethod', 'expr')
opt('w', 'foldexpr', 'nvim_treesitter#foldexpr()')

require('nvim-treesitter.configs').setup {
  ensure_installed = "all",

  refactor = {
    highlight_definitions = { enable = true },
    navigation = {
      enable = true,
      keymaps = {
        goto_definition = "gd",
        goto_next_usage = "]u",
        goto_previous_usage = "[u",
      },
    },
    --[[ smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "<leader>cr",
      },
    }, ]] -- FIXME doesn't work very well
  },

  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ib"] = "@block.inner",
        ["ab"] = "@block.outer",
      },
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
}

-- Auto Completion
paq 'hrsh7th/nvim-compe'
opt('o', 'completeopt', 'menu,menuone,noselect')

require('compe').setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'always';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;

  source = {
    path = true;
    buffer = true;
    calc = true;
    vsnip = true;
    nvim_lsp = true;
    nvim_lua = true;
    spell = true;
    tags = true;
    snippets_nvim = true;
    treesitter = true;
  };
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if fn.pumvisible() == 1 then
    return t '<CR>'
  elseif fn.call('vsnip#available', {1}) == 1 then
    return t '<Plug>(vsnip-expand-or-jump)'
  else
    return t '<Tab>'
  end
end
_G.s_tab_complete = function()
  if fn.pumvisible() == 1 then
    return t '<C-p>'
  elseif fn.call('vsnip#jumpable', {-1}) == 1 then
    return t '<Plug>(vsnip-jump-prev)'
  else
    return t '<S-Tab>'
  end
end

map('i', '<CR>', "compe#confirm('<CR>')", {expr = true, noremap = false})
map('i', '<Tab>', "v:lua.tab_complete()", {expr = true, noremap = false})
map('s', '<Tab>', "v:lua.tab_complete()", {expr = true, noremap = false})
map('i', '<S-Tab>', "v:lua.s_tab_complete()", {expr = true, noremap = false})
map('s', '<S-Tab>', "v:lua.s_tab_complete()", {expr = true, noremap = false})

-- Snippets
paq 'hrsh7th/vim-vsnip'
paq 'hrsh7th/vim-vsnip-integ'
opt('g', 'vsnip_filetypes', {javascriptreact={'javascript'}, typescript={'javascript'}, typescriptreact={'javascript'}})
opt('g', 'vsnip_snippet_dir', fn.stdpath('config') .. '/snippets')

-- LSP
opt('w', 'signcolumn', 'yes')

paq 'neovim/nvim-lspconfig'
local nvim_lsp = require('lspconfig')
local on_attach = function(client)
  print(client.name .. ' language server started' );

  -- Options
  opt('b', 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Diagnostics Signs
  fn.sign_define('LspDiagnosticsSignError', { text='', texthl='LspDiagnosticsSignError', linehl='', numhl='' })
  fn.sign_define('LspDiagnosticsSignWarning', { text='', texthl='LspDiagnosticsSignWarning', linehl='', numhl='' })
  fn.sign_define('LspDiagnosticsSignInformation', { text='', texthl='LspDiagnosticsSignInformation', linehl='', numhl='' })
  fn.sign_define('LspDiagnosticsSignHint', { text='', texthl='LspDiagnosticsSignHint', linehl='', numhl='' })

  -- Mappings
  map('n', '<C-k>', ':lua vim.lsp.buf.signature_help()<CR>')
  map('n', '<leader>ca', ':lua vim.lsp.buf.code_action()<CR>')
  map('v', '<leader>ca', ':lua vim.lsp.buf.range_code_action()<CR>')
  map('n', '<leader>cd', ':lua vim.lsp.buf.definition()<CR>')
  map('n', '<leader>cf', ':lua vim.lsp.buf.references()<CR>')
  map('n', '<leader>ci', ':lua vim.lsp.buf.implementation()<CR>')
  map('n', '<leader>cr', ':lua vim.lsp.buf.rename()<CR>')
  map('n', '<leader>cs', ':lua vim.lsp.buf.workspace_symbol()<CR>')
  map('n', '<leader>ct', ':lua vim.lsp.buf.type_definition()<CR>')
  map('n', '<leader>e', ':lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
  map('n', 'K', ':lua vim.lsp.buf.hover()<CR>')
  map('n', '[d', ':lua vim.lsp.diagnostic.goto_prev()<CR>')
  map('n', ']d', ':lua vim.lsp.diagnostic.goto_next()<CR>')
  -- map('n', '<space>cl', ':lua vim.lsp.diagnostic.set_loclist()<CR>')

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    exec([[
      hi LspReferenceRead guibg=#002A3A
      hi LspReferenceText guibg=#002A3A
      hi LspReferenceWrite guibg=#002A3A
      augroup lsp_document_highlight
        autocmd!
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end

  if client.resolved_capabilities.document_formatting then
    -- cmd 'autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()' -- FIXME doesn't work
    -- cmd 'autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()' -- FIXME causes cursor to jump to beginning of file
  end
end

-- Enable LSP snippet support
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = {
  'bashls',
  'cssls',
  'dockerls',
  'html',
  'jsonls',
  'pyls',
  'tsserver'
}

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities
  }
end

--[[ paq 'tsuyoshicho/vim-efm-langserver-settings'
-- FIXME this requires less configuration than diagnosticls gut it's very unstable:
--- it makes lighbulb fire all the time
--- disabling code actions takes no effect
--- auto formatting stops working
nvim_lsp.efm.setup {
  initializationOptions = {
    codeAction = false,
  },
} ]]

-- TODO replace all this with efm once it's more stable
nvim_lsp.diagnosticls.setup {
  on_attach=custom_attach,
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'css', 'scss', 'markdown', 'sh' },
  init_options = {
    linters = {
      eslint = {
        command = 'eslint',
        rootPatterns = { '.git' },
        debounce = 100,
        args = { '--stdin', '--stdin-filename', '%filepath', '--format', 'json' },
        sourceName = 'eslint',
        parseJson = {
          errorsRoot = '[0].messages',
          line = 'line',
          column = 'column',
          endLine = 'endLine',
          endColumn = 'endColumn',
          message = '[eslint] ${message} [${ruleId}]',
          security = 'severity'
        },
        securities = {
          [2] = 'error',
          [1] = 'warning'
        }
      },
      markdownlint = {
        command = 'markdownlint',
        rootPatterns = { '.git' },
        isStderr = true,
        debounce = 100,
        args = { '--stdin' },
        offsetLine = 0,
        offsetColumn = 0,
        sourceName = 'markdownlint',
        securities = {
          undefined = 'hint'
        },
        formatLines = 1,
        formatPattern = {
          '^.*:(\\d+)\\s+(.*)$',
          {
            line = 1,
            column = -1,
            message = 2,
          }
        }
      }
    },
    filetypes = {
      javascript = 'eslint',
      javascriptreact = 'eslint',
      typescript = 'eslint',
      typescriptreact = 'eslint',
      markdown = 'markdownlint',
      pandoc = 'markdownlint'
    },
    formatters = {
      prettierEslint = {
        command = 'prettier-eslint',
        rootPatterns = { '.git' },
        args = { '%filepath' },
      },
      prettier = {
        command = 'prettier',
        rootPatterns = { '.git' },
        args = { '--stdin-filepath', '%filename' }
      }
    },
    formatFiletypes = {
       css = 'prettier',
       javascript = 'prettierEslint',
       javascriptreact = 'prettierEslint',
       json = 'prettier',
       scss = 'prettier',
       typescript = 'prettierEslint',
       typescriptreact = 'prettierEslint'
    }
  }
}

-- LSP statusline integration
local function number_to_superscript(number)
  if number > 9 then
    return '⁹⁺'
  end
  superscript_map = { '⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹' }
  return superscript_map[number+1]
end

local function render_sign(count, sign)
  if count == 0 then
    return ''
  else
    return string.format('%s%s ', sign, number_to_superscript(count))
  end
end

function diagnostics_status()
  if vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    -- No LSP client running
    return ''
  end

  local error_count = vim.lsp.diagnostic.get_count(0, 'Error')
  local warning_count = vim.lsp.diagnostic.get_count(0, 'Warning')
  local info_count = vim.lsp.diagnostic.get_count(0, 'Information') + vim.lsp.diagnostic.get_count(0, 'Hint')
  local total_count = error_count + warning_count + info_count

  local ok_sign = '  '
  local info_sign = ' '
  local warning_sign = ' '
  local error_sign = ' '

  if total_count > 0 then
    return render_sign(info_count, info_sign)
        .. render_sign(warning_count, warning_sign)
        .. render_sign(error_count, error_sign)
  else
    return ok_sign
  end
end

exec([[
  function! DiagnosticsStatus()
    return luaeval('diagnostics_status()')
  endfunction
]], false)

-- Light bulb sign for LSP code actions
paq 'kosayoda/nvim-lightbulb'
cmd 'autocmd CursorHold,CursorHoldI * lua require("nvim-lightbulb").update_lightbulb()'
fn.sign_define("LightBulbSign", { text='', texthl='CursorLineNr', linehl='', numhl='' })

-- TODO
-- paq 'gfanto/fzf-lsp.nvim'
-- require('fzf_lsp').setup()

-- TODO
-- paq 'ojroques/nvim-lspfuzzy'
-- require('lspfuzzy').setup {}
