class ModifyForecasts < ActiveRecord::Migration
  def self.up
    change_column :forecasts, :region_id, :integer, :null => true
    change_column :forecasts, :account_exec_id, :integer, :null => true
    change_column :forecasts, :rbm_id, :integer, :null => true
  end

  def self.down
    change_column :forecasts, :region_id, :integer, :null => false
    change_column :forecasts, :account_exec_id, :integer, :null => false
    change_column :forecasts, :rbm_id, :integer, :null => false
  end
end
