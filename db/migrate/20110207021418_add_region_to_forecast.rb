require "migration_helpers"

class AddRegionToForecast < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up

    Forecast.all.each do |f|
      puts "Forecast#{f.id}"
      f.products.each do |p|
        puts "Product #{p.id}"
      end
      f.products.clear
      f.save
      f.delete
    end
    change_table :forecasts do |t|
      t.references :region, :null => false
      t.references :rbm, :null => false
      t.references :account_exec, :null => false
      t.remove :account_exec
      t.remove :rbm
    end
    add_foreign_key(:forecasts, :region_id, :lookup_codes)
    add_foreign_key(:forecasts, :rbm_id, :lookup_codes)
    add_foreign_key(:forecasts, :account_exec_id, :lookup_codes)
  end

  def self.down
    remove_foreign_key(:forecasts, :region_id)
    remove_foreign_key(:forecasts, :rbm_id)
    remove_foreign_key(:forecasts, :account_exec_id)
    change_table :forecasts do |t|
      t.remove :region_id
      t.remove :rbm_id
      t.remove :account_exec_id
      t.string :rbm
      t.string :account_exec
    end
  end
end
