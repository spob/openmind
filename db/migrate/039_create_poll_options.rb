class CreatePollOptions < ActiveRecord::Migration
  def self.up
    create_table :poll_options do |t|
      t.column :description, :string, :limit => 80, :null => false, :option => 'charset utf8'
      t.column :poll_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :poll_options
  end
end
