class CreateBugs < ActiveRecord::Migration
  def self.up
    create_table :bugs do |t|
      t.string :bug_number, :null => false
      t.string :title, :null => false
      t.text :description
      t.timestamp :pulled_from_pivotal_at
      t.timestamp :round_tripped_to_ontime_at
      t.timestamps
    end
    add_index :bugs, [:bug_number], :unique => false
  end

  def self.down
    drop_table :bugs
  end
end
