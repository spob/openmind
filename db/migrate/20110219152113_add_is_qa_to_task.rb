class AddIsQaToTask < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.boolean :qa, :null => false, :default => false
    end
    change_table :task_estimates do |t|
      t.float :remaining_qa_hours
    end
  end

  def self.down
    change_table :tasks do |t|
      t.remove :qa
    end
    change_table :task_estimates do |t|
      t.remove :remaining_qa_hours
    end
  end
end
