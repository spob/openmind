class AddCustomerFieldToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :custom_boolean1, :boolean, :null => true
    
    change_column :lookup_codes, :short_name,  :string, :limit => 40
  end

  def self.down
    remove_column :users, :custom_boolean1
    
    change_column :lookup_codes, :short_name,  :string, :limit => 20
  end
end
