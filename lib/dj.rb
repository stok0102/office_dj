class Dj < ActiveRecord::Base
  belongs_to :user
  belongs_to :song
  belongs_to :role
end
