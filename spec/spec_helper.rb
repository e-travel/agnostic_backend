$LOAD_PATH.unshift (File.dirname(__FILE__) + "/support/matchers")
require 'matchers'

require 'simplecov'
require 'simplecov-html'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start 'rails'

require 'agnostic_backend'
