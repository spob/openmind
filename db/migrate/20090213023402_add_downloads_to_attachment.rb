class AddDownloadsToAttachment < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.integer :downloads, :default => 0, :null => false
    end
  end

  def self.down
    change_table :attachments do |t|
      t.remove :downloads
    end
  end
end
