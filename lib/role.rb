class Role < ActiveRecord::Base
  has_many :users
end

if Role.count == 0
  Role.create({name: 'Administrator'})
  Role.create({name: 'TeamMember'})
end
