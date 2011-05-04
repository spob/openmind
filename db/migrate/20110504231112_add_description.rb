class AddDescription < ActiveRecord::Migration
  def self.up
    change_table :stories do |t|
      t.integer :bug_number, :null => true
      t.string :bug_description, :null => true
      t.datetime :bug_integrated_to_ontime_at, :null => true
      t.datetime :bug_integrated_to_pivotal_at, :null => true
    end
    Story.reset_column_information
    Story.find_all_by_story_type('bug').each do |b|
      b.update_attribute(:bug_number, b.parse_bug_number)
    end
  end

  def self.down
    change_table :stories do |t|
      t.remove :bug_number
      t.remove :bug_description
      t.remove :bug_integrated_to_ontime_at
      t.remove :bug_integrated_to_pivotal_at
    end
  end
end
