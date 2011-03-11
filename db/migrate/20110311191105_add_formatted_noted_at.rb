class AddFormattedNotedAt < ActiveRecord::Migration
  def self.up
    Project.all.each do |p|
      p.update_attribute(:max_note_id, 0)
    end

    StoryNote.delete_all
    change_table :story_notes do |t|
      t.string :formatted_noted_at, :null => false
    end
  end

  def self.down
    change_table :story_notes do |t|
      t.remove :formatted_noted_at
    end
  end
end
