class AddPoll < ActiveRecord::Migration
  def self.up
    create_table :polls do |t|
      t.column :title,  :string, :limit => 120, :null => false
      t.column :close_date, :date, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :polls
  end
end
