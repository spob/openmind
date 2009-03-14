require "migration_helpers"

class CreateIdeas < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :ideas, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user, :null => false
      t.references :product, :null => false
      t.references :release
      t.column :title, :string, :limit => 100, :null => false
      t.column :description, :string, :null => false
      t.timestamps
      t.column :lock_version, :integer, :default => 0
    end
      
    add_foreign_key(:ideas, :user_id, :users)
    add_foreign_key(:ideas, :product_id, :products)
    add_foreign_key(:ideas, :release_id, :releases)
  end

  def self.down
    remove_foreign_key(:ideas, :user_id)
    remove_foreign_key(:ideas, :product_id)
    remove_foreign_key(:ideas, :release_id)
    
    drop_table :ideas
  end
end
