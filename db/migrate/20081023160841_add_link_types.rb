class AddLinkTypes < ActiveRecord::Migration
  def self.up
    change_column(:links, :url, :string, :null => true)
  end

  def self.down
    change_column(:links, :url, :string, :null => false)
  end
end
