# == Schema Information
# Schema version: 20081021172636
#
# Table name: task_scheduler_batches
#
#  id          :integer(4)      not null, primary key
#  run_counter :integer(4)      default(0), not null
#  created_at  :datetime
#  updated_at  :datetime
#

class TaskSchedulerBatch < ActiveRecord::Base
  
  validates_presence_of :run_counter
  
  def self.get_next_count
    TaskSchedulerBatch.transaction do
      batch = TaskSchedulerBatch.find(:first, :lock => true)
      batch = TaskSchedulerBatch.create if batch.nil?
      batch.run_counter = batch.run_counter + 1
      batch.save
      batch.run_counter
    end
  end
  
  def self.get_batch
    TaskSchedulerBatch.find(:first)
  end
end
