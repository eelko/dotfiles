return {
  'akinsho/bufferline.nvim',
  event = 'UIEnter',
  config = function()
    vim.o.mousemoveevent = true

    require('bufferline').setup {
      highlights = {
        buffer_selected = {
          bold = false,
          italic = false,
        },
      },
      options = {
        buffer_close_icon = '',
        custom_filter = function(buf, buf_nums)
          return vim.bo[buf].filetype ~= 'qf'
        end,
        diagnostics = false,
        hover = {
          enabled = true,
          delay = 100,
          reveal = { 'close' },
        },
        indicator = {
          style = 'underline',
        },
        max_name_length = 50,
        modified_icon = '',
        offsets = {
          {
            filetype = 'NvimTree',
            text = function()
              return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            end,
            text_align = 'center',
          },
        },
      },
    }
  end,
}
