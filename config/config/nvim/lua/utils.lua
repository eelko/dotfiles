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

function _G.highlight(group, options)
  local opts = { bg = 'none', fg = 'none' }
  if options then
    opts = vim.tbl_extend('force', opts, options)
  end
  vim.api.nvim_set_hl(0, group, opts)
end

function _G.map(mode, lhs, rhs, opts)
  local options = { silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
