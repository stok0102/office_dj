class Dj < ActiveRecord::Base

  has_and_belongs_to_many :songs
  belongs_to :role
  validates :name, {presence: true, length: { in: 3..50 }, uniqueness: true}

  def request
    requests = self.requests - 1
    self.update({requests: requests})
  end

  def score (value)
    score = self.djscore + value
    self.update({djscore: score})
  end

end
