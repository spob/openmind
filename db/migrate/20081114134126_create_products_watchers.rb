require "migration_helpers"

class CreateProductsWatchers < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :products_watches, :id => false  do |t|
      t.references :user, :null => false
      t.references :product,  :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end

    add_foreign_key(:products_watches, :user_id, :users)
    add_foreign_key(:products_watches, :product_id, :products)
  end

  def self.down
    remove_foreign_key(:products_watches, :user_id)
    remove_foreign_key(:products_watches, :product_id)

    drop_table :products_watches
  end
end
