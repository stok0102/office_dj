require("bundler/setup")
Bundler.require(:default)

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

get '/' do
  erb :index
end

post 'song' do
  song = 
end
