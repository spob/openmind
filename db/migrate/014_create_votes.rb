class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.column :user_id,:integer, :null => false
      t.column :allocation_id,:integer
      t.column :idea_id,:integer
      t.column :created_at, :datetime, :null => false 
      t.column :updated_at, :datetime, :null => false
      t.column :lock_version, :integer, :default => 0
    end
  end

  def self.down
    drop_table :votes
  end
end
