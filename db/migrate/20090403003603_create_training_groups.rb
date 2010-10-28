class CreateTrainingGroups < ActiveRecord::Migration
  def self.up
    create_table :training_groups, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8'  do |t|
      t.string   :email,        :null => false
      t.string   :group_name,   :limit => 50,        :null => false
      t.datetime :processed_at
      t.string   :result
      t.column   :lock_version, :integer,            :default => 0
      t.timestamps
    end
    
    add_index :training_groups, :processed_at
  end
  
  def self.down
    drop_table :training_groups
  end
end
