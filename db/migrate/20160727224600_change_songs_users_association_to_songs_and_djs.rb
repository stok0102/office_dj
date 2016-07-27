class ChangeSongsUsersAssociationToSongsAndDjs < ActiveRecord::Migration
  def change
    drop_table :songs_users
    create_table :djs_songs do |t|
      t.integer :dj_id
      t.integer :song_id
    end  
  end
end
