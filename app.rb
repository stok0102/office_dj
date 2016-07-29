require("bundler/setup")
Bundler.require(:default)
require 'warden'
require 'rspotify'
require './config/environments'
require 'pry'
# require 'omniauth'
# require 'omniauth-oauth2'
# require 'sinatra/flash'


Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

enable :sessions
register Sinatra::Flash

use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = FailureApp
  manager.serialize_into_session {|user| user.id}
  manager.serialize_from_session {|id| User.get(id)}
end

use Warden::Manager do |config|
    config.scope_defaults :default,
      strategies: [:password],
      action: '/unauthenticated'
    config.failure_app = self
  end

Warden::Manager.before_failure do |env,opts|
  env['REQUEST_METHOD'] = 'POST'
end

Warden::Strategies.add(:password) do
  def valid?
    params["username"] || params["password"]
  end

  def authenticate!
    name = params.fetch("username")
    user = User.first(:username => name )
    if user && user.authenticate(params.fetch("password"))
      success!(user)
    else
      fail!("Could not log in")
    end
  end
end

#######Routing########

  get '/' do
    erb :index
  end

  post '/user' do
    env['warden'].authenticate!
    if env['warden'].authenticated?
      redirect "/users/#{env['warden'].user.id}"
    else
      redirect '/'
    end
  end

  # post '/unauthenticated' do
  #   erb :index
  # end

  get '/users/:id' do
    unless env['warden'].authenticated?
      redirect '/login'
    end
    @user = User.get(params.fetch("id").to_i)
    @dj = Dj.find_by(user_id: @user.id)
    if @dj.updated_at < Time.now.midnight
      @dj.reset
    end
    @songs = Library.last(10)
    @playlist = Song.where(created_at: Time.now.midnight..(Time.now.midnight + 1.day))
    @now_playing = @playlist[0]
    if @playlist.length > 0
      @current_song = Library.find(@now_playing.library_id).uri
      @current_song.slice! "spotify:track:"
    end
    @top_songs = Song.where(dj_id: @dj.id).order( 'spin_score DESC')
    @djs = Dj.all
    @role = Role.find(@dj.role_id.to_i).name
    erb(:main)
  end

  post '/song' do
    @tracks = RSpotify::Track.search(params.fetch 'name', limit: 10, market: 'US')
    @tracks.each do |track|
      artist = track.artists[0].name
      album = track.album.name
      popularity = track.popularity
      pic = track.album.images[0].fetch("url")
      duration = track.duration_ms.to_i
      uri = track.uri
      Library.create({name: track.name, artist: artist, popularity: popularity, album: album, image: pic, duration: duration, uri: uri})
    end
    redirect "/users/#{env['warden'].user.id}"
  end

  post '/song/:id' do
    dj = Dj.find params['id']
    dj.request
    Song.create({library_id: params.fetch('libraryId'), dj_id: params.fetch('id'), spin_score: 0})
    redirect "/users/#{env['warden'].user.id}"
  end

  get '/signup' do
    @roles = Role.all
    erb :signup_form
  end

  post '/users/new' do
    username = params.fetch("new_username")
    password = params.fetch("new_password")
    role_id = params.fetch("role_select").to_i
    @user = User.new({:username => username, :password => password})
    @alert = []
    if @user.save
      @alert.push("New User Created")
      dj = Dj.create({name: @user.username, user_id: @user.id, requests: 4, vetos: 1, djscore: 0, role_id: role_id})
      @songs = Library.last(10)
      erb :index
    else
      @user.errors.each do |e|
        @alert.push(e.first)
      end
      erb :index
    end
  end

  get '/login' do
    redirect '/'
  end

  get '/logout' do
    env['warden'].logout
    redirect '/'
  end

  patch '/song/:song_id/:user_id/downvote' do
    song = Song.find params['song_id']
    song_dj = Dj.find(song.dj_id)
    user_dj = Dj.find_by(user_id: params['user_id'])
    song.vote(-1)
    song.djs.push(user_dj)
    song_dj.score(-1)
    redirect "/users/#{env['warden'].user.id}"
  end

  patch '/song/:song_id/:user_id/upvote' do
    song = Song.find params['song_id']
    song_dj = Dj.find(song.dj_id)
    user_dj = Dj.find_by(user_id: params['user_id'])
    song.vote(1)
    song.djs.push(user_dj)
    song_dj.score(1)
    redirect "/users/#{env['warden'].user.id}"
  end

  delete '/song/:song_id/:user_id/veto' do
    song = Song.find params['song_id']
    song.destroy
    user_dj = Dj.find_by(user_id: params['user_id'])
    user_dj.veto
    redirect "/users/#{env['warden'].user.id}"
  end

  get '/auth/spotify/callback/' do
    hash = {"access_token":"BQCbB9n8j-0EM60h2vN7UALaODWPlRKPkhOkUn_55et34xUwurCxPJZdZTLc6tuyiGEMSB-FSRuIlHiPGg4uQbFXwS_j6a0wC9AjlnkLn-Amyokh8pjnSo3AYjNtxb7fyZktjdTiM1t-AAVr8f1HC_Bf1454taqzoJ-WdX5ldcrxQZCOlGTkUnqfjFLxZM0v6Wk_bt_PbihPv2R0useEyewYWpxeih3O0N_9YeTVpRpvlQSvBhv3ZXTcBBeQaL8XzVibug6LHVZ5","token_type":"Bearer","expires_in":3600,"refresh_token":"AQAm8-jZUQwVws86XyYtuTBVIAEWh3g1MA55cLDiMJExi4iIY-2GckloTTcmQB7nxG-cMDFi6nqrvwTIUBb8PPEYMUCK41_VcQTyROVQy-2ll7kcm7hvb0Q79Tcvhx8FRLY","scope":"playlist-read-private playlist-modify-private playlist-modify-public user-read-birthdate user-read-email user-read-private"}
    binding.pry
    spotify_user = RSpotify::User.new(hash.fetch("access_token"))
    redirect "/users/#{env['warden'].user.id}"
  end

  # post '/auth/spotify/callback/' do
  #   url = https://accounts.spotify.com/api/token
  #   code = params.fetch("code")
  #   redirect_uri = http%3A%2F%2Flocalhost%3A4567%2Fauth%2Fspotify%2Fcallback%2F
  #   grant_type = 'authorization_code'
  #   client_id = 61e71b2d2d504c6483535caa51c055b6
  #   client_secret = 4b8975a6516644b49359399b2cd30d23
  #   binding.pry
  # end

class FailureApp < Sinatra::Application
  post '/unauthenticated' do
    @alert = ['Username and/or password incorrect!']
    erb :index
  end
end
