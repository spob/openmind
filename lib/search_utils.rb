# To change this template, choose Tools | Templates
# and open the template in the editor.

class SearchUtils
  def self.rebuild_indexes
    Topic.rebuild_solr_index
    TopicComment.rebuild_solr_index
    Idea.rebuild_solr_index
    User.rebuild_solr_index
    Enterprise.rebuild_solr_index
    Attachment.rebuild_solr_index
  end
end
