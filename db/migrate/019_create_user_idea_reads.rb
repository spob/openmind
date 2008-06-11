class CreateUserIdeaReads < ActiveRecord::Migration
  def self.up
    create_table :user_idea_reads do |t|
      t.column :user_id,:integer, :null => false
      t.column :idea_id,:integer, :null => false
      t.column :last_read, :datetime, :null => false, :default => Time.now
      t.column :created_at, :datetime, :null => false 
      t.column :updated_at, :datetime, :null => false
      t.column :lock_version, :integer, :default => 0
    end
    
    add_index :user_idea_reads, :user_id
    add_index :user_idea_reads, :idea_id
  end

  def self.down
    drop_table :user_idea_reads
  end
end
