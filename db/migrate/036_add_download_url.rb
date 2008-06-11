class AddDownloadUrl < ActiveRecord::Migration
  def self.up
    add_column :releases, :download_url,  :string, :limit => 300
  end

  def self.down
    remove_column :releases, :download_url
  end
end
