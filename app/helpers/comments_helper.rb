module CommentsHelper
  def calc_return_path comment
    if comment.class.to_s == 'TopicComment'
      topic_path(comment.topic.id, :anchor => comment.id.to_s)
    else
      url_for(:controller => 'ideas', :action => 'show', :id => comment.idea, 
        :selected_tab => "COMMENTS", :anchor => comment.id.to_s)
    end
  end
end
