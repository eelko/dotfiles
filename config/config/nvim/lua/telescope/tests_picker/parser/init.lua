local logger = require 'telescope.tests_picker.logger'

local supported_filetypes = {
  javascript = 'jest',
  javascriptreact = 'jest',
  typescript = 'jest',
  typescriptreact = 'jest',
}

local bufnr = vim.api.nvim_get_current_buf()
local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
local parser_name = supported_filetypes[filetype]

if not parser_name then
  logger.warn('FileType "' .. filetype .. '" not supported by `tests` picker.')
end

local parser_path = string.format('telescope.tests_picker.parser.%s', parser_name or 'default')
local parser = require(parser_path)

return parser
