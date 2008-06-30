class AddPollOptionsUsers < ActiveRecord::Migration
  def self.up
    create_table :poll_user_responses, :id => false  do |t|
      t.column :user_id,  :integer, :null => false
      t.column :poll_option_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :poll_user_responses
  end
end
