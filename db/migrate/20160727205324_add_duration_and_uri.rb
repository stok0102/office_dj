class AddDurationAndUri < ActiveRecord::Migration
  def change
    add_column :libraries, :duration, :integer
    add_column :libraries, :uri, :string
  end
end
