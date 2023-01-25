return {
  'tpope/vim-projectionist',
  event = 'VeryLazy',
  config = function()
    local map = require('utils').map

    map('n', '<leader>aa', ':A<CR>')
    map('n', '<leader>as', ':AS<CR>')
    map('n', '<leader>av', ':AV<CR>')

    vim.g.projectionist_heuristics = {
      -- Java
      ['build.gradle'] = {
        ['src/main/*.java'] = {
          type = 'source',
          alternate = { 'src/test/{}Test.java' },
        },
        ['src/test/*Test.java'] = {
          type = 'test',
          alternate = { 'src/main/{}.java' },
        },
        ['src/test/*Tests.java'] = {
          type = 'test',
          alternate = { 'src/main/{}.java' },
        },
      },

      -- JS
      ['package.json'] = {
        ['package.json'] = {
          type = 'source',
          alternate = { 'package-lock.json' },
        },
        ['package-lock.json'] = {
          type = 'source',
          alternate = { 'package.json' },
        },
        ['*.js'] = {
          type = 'source',
          alternate = { '{}.test.js' },
        },
        ['*.test.js'] = {
          type = 'test',
          alternate = { '{}.js' },
        },

        -- TS
        ['*.jsx'] = {
          type = 'source',
          alternate = { '{}.test.jsx' },
        },
        ['*.test.jsx'] = {
          type = 'test',
          alternate = { '{}.jsx' },
        },
        ['*.ts'] = {
          type = 'source',
          alternate = { '{}.test.ts' },
        },
        ['*.test.ts'] = {
          type = 'test',
          alternate = { '{}.ts' },
        },
        ['*.tsx'] = {
          type = 'source',
          alternate = { '{}.test.tsx' },
        },
        ['*.test.tsx'] = {
          type = 'test',
          alternate = { '{}.tsx' },
        },
      },

      -- Ruby
      ['Gemfile'] = {
        ['Gemfile'] = {
          type = 'source',
          alternate = { 'Gemfile.lock' },
        },
        ['Gemfile.lock'] = {
          type = 'source',
          alternate = { 'Gemfile' },
        },
      },
    }
  end,
}
