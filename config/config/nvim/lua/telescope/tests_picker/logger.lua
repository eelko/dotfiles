local M = {}

local function log(level, msg)
  local hl_groups = { error = 'ErrorMsg', warn = 'WarningMsg' }
  local msg_hl = hl_groups[level]

  vim.cmd(string.format('echohl ' .. msg_hl .. " | echom '[Telescope] %s' | echohl NONE", msg))
end

function M.error(msg)
  log('error', msg)
end

function M.warn(msg)
  log('warn', msg)
end

return M
