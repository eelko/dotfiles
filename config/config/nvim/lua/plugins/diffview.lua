return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewFileHistory', 'DiffviewOpen' },
  dependencies = 'nvim-lua/plenary.nvim',
  init = function()
    local map = require('utils').map
    map('n', '<leader>gh', ':DiffviewFileHistory %<CR>', { desc = '[DiffView] Open Git history for current buffer' })
    map('n', '<leader>gd', ':DiffviewOpen<CR>', { desc = '[DiffView] Open diff view' })
  end,
  config = function()
    require('diffview').setup {
      enhanced_diff_hl = false,
      hooks = {
        diff_buf_read = function(bufnr)
          vim.opt_local.signcolumn = 'no'
          vim.opt_local.winbar = '%f ' .. (not vim.bo.modifiable and '' or '')
        end,
      },
      view = {
        merge_tool = {
          layout = 'diff3_mixed',
          disable_diagnostics = true,
        },
      },
    }
  end,
}
