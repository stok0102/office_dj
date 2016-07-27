class AddUriToLibraries < ActiveRecord::Migration
  def change
    add_column :libraries, :uri, :string
  end
end
