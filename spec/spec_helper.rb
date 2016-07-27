ENV['RACK_ENV'] = 'test'

require("bundler/setup")
Bundler.require(:default, :test)
set(:root, Dir.pwd())

require('capybara/rspec')
Capybara.app = Sinatra::Application
set(:show_exceptions, false)
require('./app')
require('pry')

RSpec.configure do |config|
  config.after(:each) do
    User.all().each() do |user|
      user.destroy()
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
  end
end

Dir[File.dirname(__FILE__) + '/../lib/*.rb'].each { |file| require file }
