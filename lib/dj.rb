class Dj < ActiveRecord::Base

  has_and_belongs_to_many :songs
  belongs_to :role
  validates :name, {presence: true, length: { in: 3..50 }, uniqueness: true}

  def request
    requests = self.requests - 1
    self.update({requests: requests})
  end

  def veto
    self.update({vetos: 0})
  end

  def score (value)
    score = self.djscore + value
    self.update({djscore: score})
  end

  def reset
    self.update({requests: 4, vetos: 1})
  end
end
