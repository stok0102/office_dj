configure :development do
 set :database, 'postgres://briangrant:Kod%40chrome3@localhost/office_dj'
 set :show_exceptions, true

 DataMapper.setup(:default, 'postgres://briangrant:Kod%40chrome3@localhost/office_dj')
end

configure :production do
 db = URI.parse(ENV['DATABASE_URL'] || 'postgres://briangrant:Kod%40chrome3@localhost/office_dj')

 DataMapper.setup(:default, db)

 ActiveRecord::Base.establish_connection(
   :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
   :host     => db.host,
   :username => db.user,
   :password => db.password,
   :database => db.path[1..-1],
   :encoding => 'utf8'
 )
end
