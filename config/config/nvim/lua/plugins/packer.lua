--vim.cmd 'packadd packer.nvim'

local packer_present, packer = pcall(require, 'packer')

if not packer_present then
  local packer_path = vim.fn.stdpath 'data' .. '/site/pack/packer/opt/packer.nvim'

  print 'Cloning packer...'

  vim.fn.delete(packer_path, 'rf')
  vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_path }

  vim.cmd 'packadd packer.nvim'

  packer_present, packer = pcall(require, 'packer')

  if packer_present then
    print 'Packer cloned successfully.'
  else
    error("Couldn't clone packer !\nPacker path: " .. packer_path .. '\n' .. packer)
  end
end

packer.init({
  auto_clean = true,
})

return packer
