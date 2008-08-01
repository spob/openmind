# Class representing a search hit when performing a full text search on topics
class TopicHit
  attr_reader 	:topic , 		# The topic that was found
  				:comments,		# List of matching comments
  				:topic_hit		# True iff the topic was the hit, 
  								# otherwise false if only a comment 
  								# for the topic was a hit
  
  def initialize(topic, topic_hit)
    @comments = []
    @topic_hit = topic_hit
    @topic = topic
  end
end