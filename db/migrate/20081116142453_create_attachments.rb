class CreateAttachments < ActiveRecord::Migration
  def self.up
		create_table :attachments do |t|
			t.column :filename, :string, :limit => 50, :null => false
			t.column :description, :string, :limit => 200, :null => false
			t.column :content_type, :string, :limit => 100, :null => false
      t.references :user, :null => false
      t.references :comment, :null => true
      t.column :size, :integer, :null => false
			t.column :data, :binary, :null => false
      t.timestamps
		end

    execute "ALTER TABLE attachments MODIFY COLUMN data LONGBLOB"
    add_foreign_key(:attachments, :user_id, :users)
    add_foreign_key(:attachments, :comment_id, :comments)
    add_foreign_key(:attachments, :parent_attachment_id, :attachments)
	end

	def self.down
		drop_table :attachments
	end
end
