require 'simplecov'
require 'simplecov-html'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new SimpleCov::Formatter::HTMLFormatter
SimpleCov.start

require 'agnostic_backend'
require 'agnostic_backend/rspec/matchers'

RSpec.configure do |rspec|
  rspec.include AgnosticBackend::RSpec::Matchers
  rspec.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = false
  end
end
