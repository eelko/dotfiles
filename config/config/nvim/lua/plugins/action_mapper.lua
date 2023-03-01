return {
  'obxhdx/vim-action-mapper',
  dependencies = 'nvim-telescope/telescope.nvim',
  keys = {
    { '<Leader>g', mode = { 'n', 'v' } },
  },
  config = function()
    function _G.grep_with_telescope(text)
      require('telescope.builtin').grep_string { search = vim.fn.trim(text) }
    end

    vim.cmd [[
    function! GrepWithMotion(text, type)
      call v:lua.grep_with_telescope(a:text)
    endfunction

    autocmd User MapActions call MapAction('GrepWithMotion', '<Leader>g')

    doautocmd User MapActions
    ]]
  end,
}
