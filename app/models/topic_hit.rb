# Class representing a search hit when performing a full text search on topics
class TopicHit
  attr_reader 	:topic , 		# The topic that was found
  :comments,		# List of matching comments
  :topic_hit		# True iff the topic was the hit
  # otherwise false if only a comment for the topic was a hit

  # how relevant the search score was
  attr_accessor  :score        
  
  def initialize(topic, topic_hit, score)
    @comments = []
    @topic_hit = topic_hit
    @topic = topic
    @score = score
  end

  def self.normalize_scores hits
    max_score = 0.0
    for hit in hits
      max_score = hit.score if hit.score > max_score
    end
    return if max_score == 0
    factor = 100.0/max_score
    for hit in hits
      hit.score = hit.score * factor
    end
  end
end