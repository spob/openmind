class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :user_id,:integer, :null => false
      t.column :idea_id,:integer, :null => false
      t.column :body, :string, :null => false, :option => 'charset utf8'
      t.column :created_at, :datetime, :null => false 
      t.column :updated_at, :datetime, :null => false
      t.column :lock_version, :integer, :default => 0
    end
  end

  def self.down
    drop_table :comments
  end
end
