class SeedTopicEndorsers < ActiveRecord::Migration
  def self.up
    TopicComment.reset_column_information

    for comment in TopicComment.find(:all)
      if comment.can_endorse?(comment.user)
        comment.update_attribute(:endorser, comment.user)
        comment.save
      end
    end
  end

  def self.down
    for comment in TopicComment.find(:all)
      if comment.endorsed?
        comment.update_attribute(:endorser, nil)
        comment.save
      end
    end
  end
end
