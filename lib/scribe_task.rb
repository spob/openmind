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

 
  def self.import_training_groups
    for training_group in TrainingGroup.unprocessed
      TrainingGroup.transaction do
        group = Group.find_by_name training_group.group_name
        if group.nil?
          # user group does not exist
	  set_training_group_result training_group, "User group #{training_group.group_name} does not exist"
        else
          user = User.find_by_email(training_group.email)
          if user.nil?
            # user does not exist
	    set_training_group_result training_group, "User #{training_group.email} does not exist"
          else
            # user exists and group exists
            if user.groups.include? group
              # already a member
              training_group.result = "User #{training_group.email} is already a member of the group #{training_group.group_name} (#{Time.zone.now})"
            else
              # go ahead and add this user
              training_group.result = "User #{training_group.email} added to the group #{training_group.group_name} (#{Time.zone.now})"
              user.groups << group
              user.save!
            end
	    training_group.processed_at = Time.zone.now
            training_group.save!
          end
        end
      end
    end
  end

  private

  def self.set_training_group_result training_group, result
    if training_group.result != result
      training_group.result =  result
      training_group.save!
    end
  end
end
