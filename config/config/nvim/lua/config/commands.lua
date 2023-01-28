vim.api.nvim_create_user_command('CloseOtherBuffers', function()
  local fn = vim.fn
  local all_buffers = fn.filter(fn.getbufinfo(), 'v:val.listed')
  local only_visible_buffers = fn.filter(all_buffers, 'empty(v:val.windows)')
  local buffer_numbers = fn.map(only_visible_buffers, 'v:val.bufnr')
  vim.cmd('bdelete ' .. fn.join(buffer_numbers))
end, {
  desc = 'Close all buffers except the ones visible (including split or tabs)',
})

vim.api.nvim_create_user_command('DiffToggle', function()
  if vim.o.diff then
    vim.cmd 'windo diffoff'
  else
    vim.cmd 'windo diffthis'
  end
end, {
  desc = 'Show or hide differences between all open split buffers',
})

vim.api.nvim_create_user_command('StripTrailingWhitespaces', function()
  require('utils').exec_preserving_cursor_pos '%s/\\s\\+$//g'
end, {
  desc = 'Remove all trailing white spaces from current buffer',
})

vim.api.nvim_create_user_command('Tabularize', function(t)
  vim.cmd(string.format('%s,%s!sed "s/%s/@%s/g" | column -s@ -t', t.line1, t.line2, t.args, t.args))
end, {
  nargs = 1,
  range = '%',
  desc = 'Tabularize selection using a given separator. Ex: Tabularize,',
})
