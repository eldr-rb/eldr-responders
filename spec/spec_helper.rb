if ENV['COVERALLS_REPO_TOKEN']
  require 'coveralls'
  Coveralls.wear!
end

require 'rack/test'
require 'rack'

module GlobalConfig
  extend RSpec::SharedContext
  let(:app) do
    path = File.expand_path('../examples/app.ru', File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end
end

# Hardcode an instance into a global because rack-test likes to get too clever
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include GlobalConfig

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
