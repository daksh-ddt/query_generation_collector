require 'rack/test'
require 'rspec'

require 'query_generation_collector_ws'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() QueryGenerationCollectorWS end
end

# For RSpec 2.x
RSpec.configure { |c| c.include RSpecMixin }
