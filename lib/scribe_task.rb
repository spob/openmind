# To change this template, choose Tools | Templates
# and open the template in the editor.

class ScribeTask

  def self.close_topics
    Topic.transaction do
      for topic in Topic.tracked.open
        #      puts "=====>Looking at #{topic.title}"
        nonmoderator = false
        for comment in topic.comments
          nonmoderator = true unless topic.forum.mediators.include? comment.user
          break if nonmoderator
        end
        unless nonmoderator
          #        puts "Close!!!!!!!!"
          topic = Topic.find(topic.id)
          topic.update_attribute(:open_status, false)
        end
      end
    end
  end
end
