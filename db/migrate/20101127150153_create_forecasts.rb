require "migration_helpers"

class CreateForecasts < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :forecasts do |t|
      t.references :enterprise, :null => false
      t.references :user, :null => false
      t.string :partner_representative, :null => false, :limit => 50
      t.string :account_name, :null => false, :limit => 50
      t.string :rbm, :null => false, :limit => 50
      t.string :account_exec, :null => false, :limit => 50
      t.string :location, :null => false, :limit => 50
      t.string :stage, :null => false, :limit => 25
      t.string :product, :null => false, :limit => 50
      t.date    :close_at, :null => false
      t.integer :amount, :null => false
      t.string :comments, :null => true
      t.timestamp :deleted_at, :null => true
      t.timestamps
    end
    add_foreign_key(:forecasts, :enterprise_id, :enterprises)
    add_foreign_key(:forecasts, :user_id, :users)
  end

  def self.down
    remove_foreign_key(:forecasts, :enterprise_id)
    remove_foreign_key(:forecasts, :user_id)
    drop_table :forecasts
  end
end
