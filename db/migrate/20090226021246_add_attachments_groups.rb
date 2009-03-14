require "migration_helpers"

class AddAttachmentsGroups < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :attachments_groups, :id => false  do |t|
      t.references :attachment, :null => false
      t.references :group, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end

    add_foreign_key(:attachments_groups, :attachment_id, :attachments)
    add_foreign_key(:attachments_groups, :group_id, :groups)

    add_index :attachments_groups, [:attachment_id, :group_id], :unique => true
  end

  def self.down
    remove_foreign_key(:attachments_groups, :attachment_id)
    remove_foreign_key(:attachments_groups, :group_id)

    drop_table :attachments_groups
  end
end
