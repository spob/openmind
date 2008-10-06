class AddFckEditorColumn < ActiveRecord::Migration
  # Converting app to use fckeditor instead of textile...but old entries
  # will still need to be formatted with textile for backward compatibility...
  # so add a field to determine whether this is a legacy record that needs
  # textile or a newer one that does not
  def self.up
    change_table :comments do |t|
      t.boolean :textiled, :default => false, :null => false
    end
    Comment.reset_column_information
    for comment in Comment.find(:all)
      comment.update_attribute(:textiled, true)
    end
    
    change_table :announcements do |t|
      t.boolean :textiled, :default => false, :null => false
    end
    Announcement.reset_column_information
    for announcement in Announcement.find(:all)
      announcement.update_attribute(:textiled, true)
    end
    
    change_table :ideas do |t|
      t.boolean :textiled, :default => false, :null => false
    end
    Idea.reset_column_information
    for idea in Idea.find(:all)
      idea.update_attribute(:textiled, true)
    end
    
    change_table :releases do |t|
      t.boolean :textiled, :default => false, :null => false
    end
    Release.reset_column_information
    for release in Release.find(:all)
      release.update_attribute(:textiled, true)
    end
  end

  def self.down
    change_table :comments do |t|
      t.remove :textiled
    end
    change_table :announcements do |t|
      t.remove :textiled
    end
    change_table :ideas do |t|
      t.remove :textiled
    end
    change_table :releases do |t|
      t.remove :textiled
    end
  end
end
