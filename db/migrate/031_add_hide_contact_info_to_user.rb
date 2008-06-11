class AddHideContactInfoToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :hide_contact_info, :boolean, :default => true
  end

  def self.down
    remove_column :users, :hide_contact_info
  end
end
