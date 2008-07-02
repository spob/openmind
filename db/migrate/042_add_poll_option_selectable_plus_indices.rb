class AddPollOptionSelectablePlusIndices < ActiveRecord::Migration
  def self.up
    add_index :poll_options, :poll_id, :unique => false
    add_index :poll_user_responses, [:poll_option_id, :user_id], :unique => true
    
    add_column :poll_options, :selectable, :boolean, :default => true, :null => false
  end

  def self.down
    remove_index :poll_options, :poll_id
    remove_index :poll_user_responses, [:poll_option_id, :user_id]
    
    remove_column :poll_options, :selectable
  end
end
