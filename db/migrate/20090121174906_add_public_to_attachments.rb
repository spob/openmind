class AddPublicToAttachments < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.boolean :public, :default => true, :null => false
    end
  end

  def self.down
    change_table :attachments do |t|
      t.remove :public
    end
  end
end
