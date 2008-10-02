class LengthenTopicTitle < ActiveRecord::Migration
  def self.up
    change_table :topics do |t|
      # lengthen foreign keys
      t.change :title, :string, :limit => 200
    end
  end

  def self.down
    for topic in Topic.find(:all)
      if topic.title.length > 120
        topic.title = topic.title.slice(1..120)
        topic.save
      end
    end
    change_table :topics do |t|
      # shorten foreign keys
      t.change :title, :string, :limit => 120
    end
  end
end
