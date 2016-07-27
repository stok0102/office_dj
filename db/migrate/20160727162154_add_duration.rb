class AddDuration < ActiveRecord::Migration
  def change
    add_column :libraries, :duration, :integer
  end
end
