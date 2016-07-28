require 'rubygems'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'bcrypt'
require 'dm-validations'

DataMapper.setup(:default, 'postgres://Guest:guest@localhost/office_dj')

class User < ActiveRecord::Base
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, :key => true
  property :username, String, :unique => true, :length => 3..50, :messages => {
    :is_unique => "Username already exists.",
    :length => "Username required to be between 3 and 50 characters."
  }
  property :password, BCryptHash, :length => 1..100


  has_many :djs

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!


if User.count == 0
  @user = User.create(username: "admin")
  @user.password = "admin"
  @user.save
end
