local contains = require('utils').contains

return {
  'obxhdx/vim-action-mapper',
  dependencies = 'nvim-telescope/telescope.nvim',
  keys = {
    { '<Leader>g', mode = { 'n', 'v' } },
    { '<Leader>r', mode = { 'n', 'v' } },
  },
  config = function()
    function _G.find_and_replace(text, type)
      local visual_modes = { 'v', '^V' }
      local use_word_boundary = not contains(visual_modes, type)
      local pattern = use_word_boundary and '\\<' .. text .. '\\>' or text
      local new_text = vim.fn.input('Replace ' .. pattern .. ' with: ', text)

      if #new_text > 0 then
        require('utils').exec_preserving_cursor_pos(',$s/' .. pattern .. '/' .. new_text .. '/gc')
      end
    end

    vim.cmd [[
    function! FindAndReplace(text, type)
      call v:lua.find_and_replace(a:text, a:type)
    endfunction
    autocmd User MapActions call MapAction('FindAndReplace', '<Leader>r')

    " Telescope integration
    function! GrepWithMotion(text, type)
      execute('lua require("telescope.builtin").grep_string({search = "'.trim(a:text).'"})')
    endfunction
    autocmd User MapActions call MapAction('GrepWithMotion', '<Leader>g')

    doautocmd User MapActions
    ]]
  end,
}
