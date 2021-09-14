-- Utility funcions and aliases
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

-- Set custom path for plugins
local package_root = fn.stdpath('config') .. '/plugins'
vim.opt.packpath:append(package_root)

-- Bootstrap package manager
local packer_path = package_root .. '/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(packer_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_path})
end

cmd 'packadd packer.nvim'

local packer = require('packer')
local util = require('packer.util')

packer.init({
  package_root = util.join_paths(package_root, 'pack'),
  compile_path = util.join_paths(fn.stdpath('config'), 'plugins', 'packer_compiled.lua'),
  display = {
    open_fn = require('packer.util').float,
  },
})

-- Regenerate compiled loader file whenever this file is updated
cmd([[
  augroup PackerUserConfig
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
    autocmd User PackerCompileDone call SanitizeColors()
  augroup end
]])

-- Declare plugins
return packer.startup(function()
  -- Let Packer manage itself
  use { 'wbthomason/packer.nvim' }

  -- Colors
  use { 'sjl/badwolf' }
  cmd 'try | colorscheme badwolf | catch | endtry'
  cmd([[
  function! SanitizeColors()
    hi CursorLine guibg=#444444
    hi LineNr guibg=NONE
    hi MatchParen guibg=NONE
    hi Normal guibg=NONE
    hi NormalNC guibg=#3a3a3a
    hi Pmenu guifg=#f8f6f2 guibg=#484A55
    hi PmenuSbar guibg=#2B2C31
    hi PmenuThumb guibg=grey
    hi SignColumn guibg=NONE
    hi StatusLineNC gui=bold guifg=gray guibg=#262626
    hi VertSplit guibg=#262626 guifg=#262626
    hi VertSplit guifg=#3a3a3a guibg=#3a3a3a
    hi Visual guibg=#626262

    hi! link ColorColumn CursorLine

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
  ]])

  -- Tabline aesthetics
  use { 'ap/vim-buftabline' }
  opt('g', 'buftabline_show', true)
  opt('g', 'buftabline_indicators', true)
  opt('g', 'buftabline_numbers', 2)
  map('n', '<leader>1', '<Plug>BufTabLine.Go(1)', {noremap = false})
  map('n', '<leader>2', '<Plug>BufTabLine.Go(2)', {noremap = false})
  map('n', '<leader>3', '<Plug>BufTabLine.Go(3)', {noremap = false})
  map('n', '<leader>4', '<Plug>BufTabLine.Go(4)', {noremap = false})
  map('n', '<leader>5', '<Plug>BufTabLine.Go(5)', {noremap = false})
  map('n', '<leader>6', '<Plug>BufTabLine.Go(6)', {noremap = false})
  map('n', '<leader>7', '<Plug>BufTabLine.Go(7)', {noremap = false})
  map('n', '<leader>8', '<Plug>BufTabLine.Go(8)', {noremap = false})
  map('n', '<leader>9', '<Plug>BufTabLine.Go(9)', {noremap = false})
  map('n', '<leader>0', '<Plug>BufTabLine.Go(10)', {noremap = false})
  cmd([[
    hi BufTabLineCurrent gui=bold guibg=#ff5f5f guifg=#080808
    hi BufTabLineActive  gui=bold guibg=#3a3a3a guifg=#ff5f5f
    hi BufTabLineHidden  gui=bold guibg=#3a3a3a guifg=#D5C4A1
    hi BufTabLineFill    gui=bold guibg=#3a3a3a guifg=#D5C4A1
  ]])

  -- Language pack
  use { 'sheerun/vim-polyglot' }
  opt('g', 'vim_markdown_conceal', false)
  opt('g', 'vim_markdown_conceal_code_blocks', false)

  -- Git sings on gutter
  use { 'mhinz/vim-signify' }
  opt('g', 'signify_sign_show_count', false)
  opt('g', 'signify_priority', 5)
  opt('g', 'signify_sign_add', '│')
  opt('g', 'signify_sign_delete', '│')
  opt('g', 'signify_sign_delete_first_line', '│')
  opt('g', 'signify_sign_change', '│')
  opt('g', 'signify_sign_changedelete', '│')
  cmd([[
    hi SignifySignAdd    guifg=#9BB76D guibg=NONE
    hi SignifySignChange guifg=#00AFFF guibg=NONE
    hi SignifySignDelete guifg=#FF5F5F guibg=NONE
  ]])

  -- Indentation guides
  use { 'yggdroot/indentLine' }
  opt('g', 'indentLine_faster', 1)
  opt('g', 'indentLine_char', '┊')

  -- Auto pairs
  use { 'tmsvg/pear-tree' }
  opt('g', 'pear_tree_repeatable_expand', false)
  opt('g', 'pear_tree_ft_disabled', {''}) -- Disable when no filetype: workaround for new coc input prompt
  cmd 'au FileType * imap <buffer> <Space> <Plug>(PearTreeSpace)'

  -- Tmux integration
  use { 'christoomey/vim-tmux-navigator' }
  opt('g', 'tmux_navigator_no_mappings', true)
  map('n', '<m-h>', ':TmuxNavigateLeft<CR>')
  map('n', '<m-j>', ':TmuxNavigateDown<CR>')
  map('n', '<m-k>', ':TmuxNavigateUp<CR>')
  map('n', '<m-l>', ':TmuxNavigateRight<CR>')

  -- File explorer
  use { 'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  local nvim_tree_present, nvim_tree_config = pcall(require, 'nvim-tree.config')

  if nvim_tree_present then
    local tree_cb = nvim_tree_config.nvim_tree_callback
    opt('g', 'nvim_tree_bindings', {
        { key = 'C', cb = tree_cb('cd') },
        { key = 'u', cb = tree_cb('dir_up') },
        { key = 'x', cb = tree_cb('close_node') },
      })
  end

  opt('g', 'nvim_tree_follow', 1)
  opt('g', 'nvim_tree_git_hl', 0)
  opt('g', 'nvim_tree_icons', { default='', symlink='' })
  opt('g', 'nvim_tree_ignore', { '.git' })
  opt('g', 'nvim_tree_indent_markers', 1)
  opt('g', 'nvim_tree_show_icons', { git=0, folders=1, files=1 })
  opt('g', 'nvim_tree_auto_resize', 0)
  opt('g', 'nvim_tree_root_folder_modifier', ':t')
  map('n', '<leader>nf', ':NvimTreeFindFile<CR>')
  map('n', '<leader>nt', ':NvimTreeToggle<CR>')

  -- Quickly comment code
  use { 'tpope/vim-commentary' }

  -- Turn quickfix buffer editable
  use { 'itchyny/vim-qfedit' }

  -- Readline keymaps for command bar
  use { 'tpope/vim-rsi' }

  -- Quickly surround with quotes/parens/etc
  use { 'tpope/vim-surround' }
  use { 'tpope/vim-repeat' } -- Enable "." repeat for surround

  -- Markdown previewer
  use { 'iamcco/markdown-preview.nvim', run = ':call mkdp#util#install()' }

  -- Documentation generator
  use { 'kkoomen/vim-doge', run = ':call doge#install()' }
  opt('g', 'doge_enable_mappings', 0)

  -- Statusline aesthetics
  use { 'glepnir/galaxyline.nvim', branch = 'main', requires = { 'kyazdani42/nvim-web-devicons' } }
  require('statusline')

  -- Faster text navigation
  use { 'justinmk/vim-sneak' }
  opt('g', 'sneak#label', 1)

  -- Project configurations
  use { 'tpope/vim-projectionist' }
  map('n', '<leader>aa', ':A<CR>')
  map('n', '<leader>as', ':AS<CR>')
  map('n', '<leader>av', ':AV<CR>')

  -- Actions with motions
  use { 'obxhdx/vim-action-mapper' }
  cmd([[
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
   let supported_languages = { 'java': 'System.out.println("==> %s: " + %s);', 'javascript': javascript_template, 'javascript.jsx': javascript_template, 'javascriptreact': javascript_template, 'python': "print('==> %s:', %s)", 'ruby': 'puts ("==> %s: #{%s}")', 'typescript': javascript_template, 'typescript.jsx': javascript_template, 'typescriptreact': javascript_template }
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
  ]])

  -- FZF
  use { 'junegunn/fzf', run = ':call fzf#install()' }
  use { 'junegunn/fzf.vim' }
  opt('g', 'fzf_layout', { window = { width = 0.7, height = 0.4 } })
  opt('g', 'projectionist_ignore_term', 1)
  map('n', '<leader>fb', ':Buffers<CR>')
  map('n', '<leader>fc', ':Commands<CR>')
  map('n', '<leader>ff', ':Files<CR>')
  map('n', '<leader>fh', ':History:<CR>')
  map('n', '<leader>fl', ':BLines<CR>')
  map('n', '<leader>fr', ':History<CR>')

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {
      'JoosepAlviste/nvim-ts-context-commentstring',
      'nvim-treesitter/nvim-treesitter-refactor',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
  }

  local treesitter_present, treesitter_config = pcall(require, 'nvim-treesitter.configs')

  if treesitter_present then
    opt('w', 'foldmethod', 'expr')
    opt('w', 'foldexpr', 'nvim_treesitter#foldexpr()')

    treesitter_config.setup {
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
  end

  -- CoC
  use { 'neoclide/coc.nvim', branch = 'release' }

  opt('g', 'coc_node_path', fn.expand('$LATEST_NODE_PATH')) -- Custom node path
  opt('w', 'signcolumn', 'yes') -- Make sign column always visible even when empty

  cmd 'hi CocErrorFLoat guifg=#FF7276' -- A shade of red that is easier on the eyes
  cmd 'hi CocFloatBorder guifg=black guibg=none gui=bold'
  cmd 'hi! link CocFadeOut Noise' -- Make unused vars easier to see

  -- Enhanced keyword lookup
  map('n', 'K', ':call CocActionAsync("doHover")<CR>')

  -- Code navigation mappings
  map('n', '<leader>cd', '<Plug>(coc-definition)', {noremap = false})
  map('n', '<leader>ct', '<Plug>(coc-type-definition)', {noremap = false})
  map('n', '<leader>ci', '<Plug>(coc-implementation)', {noremap = false})
  map('n', '<leader>cf', '<Plug>(coc-references)', {noremap = false})
  map('n', '<leader>cr', '<Plug>(coc-rename)', {noremap = false})

  -- Applying codeAction to the selected region
  map('x', '<leader>ca', '<Plug>(coc-codeaction-selected)', {noremap = false})
  map('n', '<leader>ca', '<Plug>(coc-codeaction-selected)', {noremap = false})

  -- Applying codeAction to the current buffer
  map('n', '<leader>caa', '<Plug>(coc-codeaction)', {noremap = false})

  -- Easily navigate diagnostics
  -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
  map('n', '[d', '<Plug>(coc-diagnostic-prev)', {noremap = false})
  map('n', ']d', '<Plug>(coc-diagnostic-next)', {noremap = false})

  -- Use Tab to trigger completion, snippet expansion and placeholder navigation
  opt('g', 'coc_snippet_next', '<TAB>')
  opt('g', 'coc_snippet_prev', '<S-TAB>')
  map('i', '<TAB>', 'pumvisible() ? coc#_select_confirm() : CheckBackSpace() ? "<TAB>" : coc#refresh()', {noremap = true, expr = true, silent = true})
  cmd([[
    function! CheckBackSpace() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction
  ]])

  -- Echo method signatures on snippet expansion and in instert mode
  cmd([[
    function! ShowCodeSignature()
      if exists('*CocActionAsync') && &ft =~ '\(java\|type\)script\(react\)\?'
        call CocActionAsync('showSignatureHelp')
      endif
    endfunction

    augroup ShowCodeSignature
      autocmd!
      autocmd User CocJumpPlaceholder call ShowCodeSignature()
      autocmd CursorHoldI * call ShowCodeSignature()
    augroup END
  ]])

  -- CoC + FZF integration
  use { 'antoinemadec/coc-fzf' }
  map('n', '<leader>cc', ':CocFzfList commands<CR>', {noremap = false})
  map('n', '<leader>co', ':CocFzfList outline<CR>', {noremap = false})
  map('n', '<leader>cs', ':CocFzfList symbols<CR>', {noremap = false})

  -- Config pack for the efm LSP
  use { 'tsuyoshicho/vim-efm-langserver-settings' }

  -- Visual indicator when code acions are available
  use { 'xiyaowong/coc-lightbulb' }

  fn.sign_define('LightBulbSign', { text = '', texthl = 'LspDiagnosticsDefaultInformation' })

  local lightbulb_present, lightbulb = pcall(require, 'coc-lightbulb')

  if lightbulb_present then
    lightbulb.setup {
      sign = {
        enabled = true,
        priority = 100,
      },
    }
  end
end)
