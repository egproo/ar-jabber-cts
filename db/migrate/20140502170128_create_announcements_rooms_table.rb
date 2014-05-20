class CreateAnnouncementsRoomsTable < ActiveRecord::Migration
  def up
    create_table :announcements_rooms, id: false do |t|
      t.belongs_to :announcement
      t.belongs_to :room
    end
    add_index :announcements_rooms, [:announcement_id, :room_id], unique: true
  end

  def down
    drop_table :announcements_rooms
  end
end
