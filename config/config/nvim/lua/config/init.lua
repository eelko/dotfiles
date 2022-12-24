require 'config.options'
require 'config.mappings'
require 'config.commands'
require 'config.autocommands'
require 'config.lazy'

pcall(require, 'config.local') -- Load local settings that will not be added to version control
