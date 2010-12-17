class AddStatusToTaskEstimate < ActiveRecord::Migration
  def self.up
    change_table :task_estimates do |t|
      t.string :status
    end
  end

  def self.down
    change_table :task_estimates do |t|
      t.remove :status
    end
  end
end
