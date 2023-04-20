return require('telescope').register_extension {
  exports = {
    current_buffer_tests = require('telescope.tests_picker').current_buffer_tests,
  },
}
