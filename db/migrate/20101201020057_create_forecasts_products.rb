require "migration_helpers"

class CreateForecastsProducts < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :forecasts_products, :id => false  do |t|
      t.references :forecast, :null => false
      t.references :product, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end

    add_foreign_key(:forecasts_products, :forecast_id, :forecasts)
    add_foreign_key(:forecasts_products, :product_id, :products)

    add_index :forecasts_products, [:forecast_id, :product_id],
      :unique => true #, :name => ':enterprise_types_forums_u1'
  end

  def self.down
    remove_foreign_key(:forecasts_products, :forecast_id)
    remove_foreign_key(:forecasts_products, :product_id)

    drop_table :forecasts_products
  end
end
