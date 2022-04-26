function _G.contains(list, value)
  for _, v in pairs(list) do
    if v == value then
      return true
    end
  end
  return false
end

function _G.exec_preserving_cursor_pos(command)
  -- Run commands (e.g. substitution) and restore previous cursor position
  local current_view = vim.fn.winsaveview()
  vim.api.nvim_exec('keeppatterns ' .. command, false)
  vim.fn.histadd('cmd', command)
  vim.fn.winrestview(current_view)
end

function _G.highlight(group, bg, fg, gui)
  bg = bg or 'none'
  fg = fg or 'none'
  gui = gui or 'none'
  vim.api.nvim_command(('hi %s guibg=%s guifg=%s gui=%s'):format(group, bg, fg, gui))
end

function _G.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
