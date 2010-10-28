class AddDeltaToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :delta, :boolean, :default => true,
    :null => false
  end
  
  def self.down
    change_table :attachments do |t|
      t.remove :delta
    end
  end
end
