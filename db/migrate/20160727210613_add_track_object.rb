class AddTrackObject < ActiveRecord::Migration
  def change
    add_column :libraries, :track_object, :object
  end
end
