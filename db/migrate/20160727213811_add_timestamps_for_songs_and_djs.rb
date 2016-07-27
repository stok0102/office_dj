class AddTimestampsForSongsAndDjs < ActiveRecord::Migration
  def change
    add_column(:songs, :created_at, :datetime)
    add_column(:songs, :updated_at, :datetime)
    add_column(:djs, :created_at, :datetime)
    add_column(:djs, :updated_at, :datetime)
  end
end
