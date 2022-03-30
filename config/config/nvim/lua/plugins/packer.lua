vim.cmd 'packadd packer.nvim'

local packer_present, packer = pcall(require, 'packer')

if not packer_present then
  local packer_path = vim.fn.stdpath 'data' .. '/site/pack/packer/opt/packer.nvim'

  vim.fn.delete(packer_path, 'rf')
  vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_path }

  vim.cmd 'packadd packer.nvim'

  packer_present, packer = pcall(require, 'packer')

  if packer_present then
    error("Couldn't clone packer !\nPacker path: " .. packer_path .. '\n' .. packer)
  end
end

packer.init({
  auto_clean = true,
  auto_reload_compiled = false,
})

return packer
