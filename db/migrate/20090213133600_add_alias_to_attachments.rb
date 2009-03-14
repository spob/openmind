class AddAliasToAttachments < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.string :alias, :null => true, :limit => 40
    end
    add_index :attachments, :alias, :unique => true
  end

  def self.down
    remove_index :attachments, :alias
    change_table :attachments do |t|
      t.remove :alias
    end
  end
end
