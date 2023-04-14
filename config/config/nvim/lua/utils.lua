local M = {}

function M.contains(list, value)
  for _, v in pairs(list) do
    if v == value then
      return true
    end
  end
  return false
end

-- Run commands (e.g. substitution) and restore previous cursor position
function M.exec_preserving_cursor_pos(command)
  local current_view = vim.fn.winsaveview()
  vim.api.nvim_exec('keeppatterns ' .. command, false)
  vim.fn.histadd('cmd', command)
  vim.fn.winrestview(current_view)
end

function M.highlight(group, options)
  local opts = { bg = 'none', fg = 'none' }
  if options then
    opts = vim.tbl_extend('force', opts, options)
  end
  vim.api.nvim_set_hl(0, group, opts)
end

function M.map(mode, lhs, rhs, opts)
  local options = { silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

--- Closes the current buffer in a "clever" way.
--
-- This function closes the current buffer and switches to the next buffer or
-- the previous one, depending on its position in the buffer list. If the
-- current buffer is the last listed buffer, it switches to the previous buffer
-- (':bp'). Otherwise, it switches to the next buffer (':bn').
--
-- This behavior is based on the original Vimscript mapping found at
-- reddit.com/em9qvv.
function M.clever_close()
  -- Get the current buffer number
  local current_buf = vim.api.nvim_get_current_buf()

  -- Get the list of all buffer numbers
  local listed_buffers = vim.api.nvim_list_bufs()

  -- Initialize the last listed buffer variable
  local last_listed_buf = nil

  -- Iterate through the buffer list to find the last listed buffer
  for _, buf in ipairs(listed_buffers) do
    if vim.api.nvim_buf_get_option(buf, 'buflisted') then
      last_listed_buf = buf
    end
  end

  -- If the current buffer is the last listed buffer, switch to the previous buffer
  if current_buf == last_listed_buf then
    vim.cmd 'bp'
    -- Otherwise, switch to the next buffer
  else
    vim.cmd 'bn'
  end

  -- Delete the buffer that was originally current
  vim.cmd 'bd #'
end

--- Switches to the next or previous buffer based on the given direction.
-- This function switches the buffer `count` times in the specified direction ('next' or 'previous').
-- It sets a mark in the current buffer before switching, allowing you to return to the original buffer
-- with <C-o>. It does nothing if the current buffer's `buftype` is not empty.
-- @param direction string: 'next' or 'previous', indicating the direction to switch the buffer
function M.switch_buffer(direction)
  if vim.bo.buftype ~= '' then
    return
  end

  local count = vim.v.count1 > 0 and vim.v.count1 or 1
  local bufnr = vim.api.nvim_get_current_buf()
  local total_buffers = vim.fn.bufnr '$'

  -- Set a mark in the current buffer
  vim.cmd "normal! m'"

  for _ = 1, count do
    repeat
      if direction == 'next' then
        bufnr = bufnr % total_buffers + 1
      else
        bufnr = bufnr - 1
        if bufnr < 1 then
          bufnr = total_buffers
        end
      end
    until vim.fn.buflisted(bufnr) == 1
  end

  vim.cmd('keepjumps ' .. 'buf ' .. bufnr)
end

return M
