vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, {
  desc = 'Auto save buffers when focus is lost',
  callback = function()
    local buffer_has_name = vim.fn.empty(vim.fn.bufname '%') == 0
    if buffer_has_name and vim.o.modified then
      vim.cmd 'write'
    end
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text (requires NeoVim 0.6+)',
  callback = function()
    vim.highlight.on_yank { higroup = 'Visual', timeout = 200 }
  end,
})

vim.api.nvim_create_autocmd('VimLeave', {
  desc = 'Restore terminal cursor when leaving editor',
  command = 'set guicursor=a:hor20',
})

vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Resize all splits when host window is resized',
  command = 'wincmd =',
})
