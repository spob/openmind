class CreateIdeas < ActiveRecord::Migration
  def self.up
    create_table :ideas, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.column :user_id, :integer, :null => false
      t.column :product_id, :integer, :null => false
      t.column :release_id, :integer
      t.column :title, :string, :limit => 100, :null => false
      t.column :description, :string, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false 
      t.column :lock_version, :integer, :default => 0
    end
  end

  def self.down
    drop_table :ideas
  end
end
