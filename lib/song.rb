class Song < ActiveRecord::Base
  has_and_belongs_to_many :djs

  def vote (value)
    spin_score = self.spin_score + value
    self.update({spin_score: spin_score})
  end
end
