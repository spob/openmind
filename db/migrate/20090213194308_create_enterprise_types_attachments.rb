
require "migration_helpers"

class CreateEnterpriseTypesAttachments < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :attachments_enterprise_types, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8', :id => false  do |t|
      t.references :attachment, :null => false
      t.references :enterprise_type, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end

    add_foreign_key(:attachments_enterprise_types, :attachment_id, :attachments)
    add_foreign_key(:attachments_enterprise_types, :enterprise_type_id, :lookup_codes)

    add_index :attachments_enterprise_types, [:attachment_id, :enterprise_type_id],
      :unique => true, :name => ':attachments_enterprise_types_u1'
  end

  def self.down
    remove_foreign_key(:attachments_enterprise_types, :attachment_id)
    remove_foreign_key(:attachments_enterprise_types, :enterprise_type_id)

    drop_table :attachments_enterprise_types
  end
end
