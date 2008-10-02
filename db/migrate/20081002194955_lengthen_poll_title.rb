class LengthenPollTitle < ActiveRecord::Migration
  def self.up
    change_table :polls do |t|
      # lengthen foreign keys
      t.change :title, :string, :limit => 200
    end
  end

  def self.down
    for poll in Poll.find(:all)
      if poll.title.length > 120
        poll.title = poll.title.slice(1..120)
        poll.save
      end
    end
    change_table :polls do |t|
      # shorten foreign keys
      t.change :title, :string, :limit => 120
    end
  end
end
