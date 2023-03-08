return {
  'sindrets/diffview.nvim',
  keys = {
    {
      '<leader>gh',
      ':DiffviewFileHistory %<CR>',
      desc = '[DiffView] Open Git history for current buffer',
      silent = true,
    },
    { '<leader>gd', ':DiffviewOpen<CR>', desc = '[DiffView] Open diff view', silent = true },
  },
  dependencies = 'nvim-lua/plenary.nvim',
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
