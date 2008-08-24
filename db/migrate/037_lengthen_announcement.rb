class LengthenAnnouncement < ActiveRecord::Migration
  def self.up
    change_column :announcements, :headline, :string, :limit => 120
  end

  def self.down
    change_column :announcements, :headline, :string, :limit => 80
  end
end
