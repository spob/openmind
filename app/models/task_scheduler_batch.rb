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
