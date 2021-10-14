cmd = vim.cmd
exec = vim.api.nvim_exec
fn = vim.fn
scopes = { o = vim.o, b = vim.bo, g = vim.g, w = vim.wo }

function map(mode, lhs, rhs, opts)
  options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function opt(scope, key, value)
  scopes[scope][key] = value
end

function isempty(s)
  return s == nil or s == ''
end

function print_table(t)
  for k, v in pairs(t) do
    print(k, v)
  end
end

function contains(list, value)
  for _, v in pairs(list) do
    if v == value then
      return true
    end
  end
  return false
end
