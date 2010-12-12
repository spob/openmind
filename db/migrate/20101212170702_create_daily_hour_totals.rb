require "migration_helpers"

class CreateDailyHourTotals < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :daily_hour_totals do |t|
      t.references :iteration, :null => false
      t.date :as_of, :null => false
      t.float :total_hours, :null => false
      t.float :remaining_hours, :null => false
      t.float :points_delivered, :null => false
      t.float :velocity, :null => false

      t.timestamps
    end
    add_foreign_key(:daily_hour_totals, :iteration_id, :iterations)
    add_index :daily_hour_totals, [:iteration_id, :as_of], :unique => true
  end

  def self.down
    remove_foreign_key(:daily_hour_totals, :iteration_id)
    drop_table :daily_hour_totals
  end
end
