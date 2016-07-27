class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
    end

    add_column :djs, :role_id, :integer

  end
end
