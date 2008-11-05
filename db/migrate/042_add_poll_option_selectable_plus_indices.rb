class AddPollOptionSelectablePlusIndices < ActiveRecord::Migration
  def self.up
    add_index :poll_options, [:description]
    
    add_column :poll_options, :selectable, :boolean, :default => true, :null => false
  end

  def self.down 
    change_table :poll_options do |t|
      t.remove_index [:description]
      t.remove :selectable
    end
  end
end
