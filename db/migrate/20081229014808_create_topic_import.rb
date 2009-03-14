class CreateTopicImport < ActiveRecord::Migration
  def self.up
    create_table :topic_imports, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :forum_name, :limit => 50, :null => false
      t.string :topic_title, :limit => 200, :null => false
      t.string :user_email, :null => false
      t.text :comment_body, :null => false
      t.timestamps
      t.string :status
    end
    RunIntervalPeriodicJob.create(:job => 'TopicImport.process',
      :interval => 600) #once every 10 minutes
  end

  def self.down
    drop_table :topic_imports
    RunIntervalPeriodicJob.find_by_job("TopicImport.process").destroy
  end
end
