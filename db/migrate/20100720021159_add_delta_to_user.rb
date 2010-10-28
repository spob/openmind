class AddDeltaToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :delta, :boolean, :default => true,
    :null => false
  end
  
  def self.down
    change_table :users do |t|
      t.remove :delta
    end
   end
end
