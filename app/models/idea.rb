class Idea < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :user
  belongs_to :release
  belongs_to :product
  has_one :last_comment, :class_name => "IdeaComment", :order => "id DESC"
  has_many :votes,:dependent => :destroy, :order => "id ASC"   
  has_many :comments,:dependent => :destroy, :order => "id ASC"
  has_many :user_idea_reads,:dependent => :destroy 
  belongs_to :merged_to_idea, :class_name => 'Idea', :foreign_key => :merged_to_idea_id
  has_many :merged_ideas, :class_name => 'Idea', :foreign_key => :merged_to_idea_id
  # This collection is for watches
  has_and_belongs_to_many :watchers, :join_table => 'watches', :class_name => 'User'
  
  # validates_presence_of :user_id, :product_id, :release_id
  validates_presence_of :user_id, :product_id
  validates_presence_of :title, :description
  validates_uniqueness_of :title
  validates_length_of :title, :maximum => 100
  
  def self.list_watched_ideas(page, user, properties)
    list(page, user, properties, 
      " exists (select null from watches as w where w.idea_id = ideas.id and w.user_id = ?)",
      user.id)
  end
  
  def self.list_unread_ideas(page, user, properties)
    list(page, user, properties, 
      "not exists (select null from user_idea_reads as uir where uir.idea_id = ideas.id and uir.user_id = ?)",
      user.id)
  end
  
  def self.list_unread_comments(page, user, properties)
    list(page, user, properties, 
      "exists (select null from comments as c where c.idea_id = ideas.id and c.created_at > ifnull(user_idea_reads.last_read, makedate(1900,1)))",
      nil ,
      "LEFT OUTER JOIN user_idea_reads ON user_idea_reads.idea_id = ideas.id and user_idea_reads.user_id = #{user.id}")
  end
  
  def self.list_most_votes(page, user, properties)
    list(page, user, properties, 
      nil,
      nil,
      "INNER JOIN votes ON votes.idea_id = ideas.id",
      'count(votes.id) DESC', 
      'ideas.id')
  end
  
  def self.list_most_views(page, user, properties)
    list(page, user, properties, 
      nil,
      nil,
      nil,
      'view_count DESC')
  end
  
  # list ideas the user has voted on
  def self.list_voted_ideas(page, user, properties)
    list(page, user, properties, 
      "exists (select null from votes as v where v.idea_id = ideas.id and v.user_id = ?)",
      user.id)
  end
  
  # list ideas the user created
  def self.list_my_ideas(page, user, properties)
    list(page, user, properties, 
      "ideas.user_id = ?",
      user.id)
  end
  
  # list ideas the user has commented on
  def self.list_commented_ideas(page, user, properties)
    list(page, user, properties, 
      "exists (select null from comments as c where c.idea_id = ideas.id and c.user_id = ?)",
      user.id)
  end
  
  def self.list(page, user, properties, 
      condition_string = nil, pcondition_params = nil, joins = nil,
      order_by = 'ideas.created_at DESC', group_by = nil)
    condition_params ||= [""]
    
    filter_by_author = properties[:author_filter]
    # author filter
    condition_params = add_criteria(condition_params, 
      "ideas.user_id = ?", 
      filter_by_author) unless filter_by_author.to_i == 0
    
    filter_by_product = properties[:product_filter]
    # product filter
    condition_params = add_criteria(condition_params, 
      "product_id = ?", 
      filter_by_product) unless filter_by_product.to_i == 0
    
    filter_by_release = properties[:release_filter]
    # product filter
    condition_params = add_criteria(condition_params, 
      "release_id = ?", 
      filter_by_release) unless filter_by_release.to_i <= 0
    condition_params = add_criteria(condition_params, 
      "release_id is null") if filter_by_release.to_i == 0
    
    title_filter = properties[:title_filter]
    # title filter
    condition_params = add_criteria(condition_params, 
      "title like ?", 
      "%#{title_filter}%") unless title_filter.nil? or title_filter.length == 0
    
    condition_params = add_criteria(condition_params, 
      condition_string, 
      pcondition_params) unless condition_string.nil?
    
    # no criteria set...null out the condition_params or you'll get a sql error
    condition_params = nil if condition_params[0] == ""
    paginate :page => page, 
      :conditions => condition_params,
      :joins => joins,
      :order => order_by, 
      :group => group_by,
      :per_page => user.row_limit, :include => ['product']
  end
  
  def self.paginate_list ideas, page, per_page
    paginate :page => page, 
      :per_page => per_page,
      :conditions => ["id in (?)", ideas.collect(&:id)]
  end
  
  def user_friendly_idea_name
    "#{id}: #{title}"
  end
  
  def unread?(user)
    user_idea_reads.find_by_user_id(user.id).nil?
  end
  
  def unread_comment?(user)
    # if no comments, then return false
    return false if comments.nil? or comments.empty?
    
    read = user_idea_reads.find_by_user_id(user.id)
    # idea never been read so comments must be unread
    return true if read.nil?
    
    !comments.find(:first, :conditions => ["comments.created_at > ?", read.last_read]).nil?
  end
  
  def formatted_description
    r = RedCloth.new description
    r.to_html
  end
  
  def last_comment? comment
    return false if last_comment.nil?
    comment.id == last_comment.id
  end

  def can_delete?
    # Criteria is the same as can_edit (at least for now)
    can_edit?
  end  

  def can_edit?
    # Can only delete votes for which there are no comments and not votes
    votes.empty? and comments.empty? 
  end  
  
  def rescindable_votes?(user_id)
    !votes.find(:first, :conditions => ['created_at > ? and user_id = ?', 
        (Time.now - Vote.rescind_seconds).to_s(:db), user_id]).nil?
  end
  
  def rescind_vote(user)
    vote = votes.find(:first, 
      :conditions => ['created_at > ? and user_id = ?', 
        (Time.now - Vote.rescind_seconds).to_s(:db), user.id],
      :order => 'created_at DESC')
   
    raise VoteException if vote.nil?
    vote.destroy
  end
  
  def vote(user)
    # first try to consume the user allocations
    found = allocation_votes user.active_allocations,
      user
    # if that didn't work, try to consume the enterprise allocations
    found = allocation_votes(user.enterprise.active_allocations,
      user) unless found
    raise VoteException unless found
  end
  
  # list of all users who have created an idea
  def self.authors    
    @users = User.find(:all,
      :conditions => "exists (select null from ideas as i where i.user_id = users.id)",
      :order => 'email')
  end
  
  # merge this idea into another idea. The merged_to_idea field will be populated,
  # and any votes for this idea will be transferred to the target idea
  def merge_into target_idea
    self.merged_to_idea = target_idea
    
    # transfer votes
    for vote in self.votes
      vote.comments = "Reassigned from idea number #{self.id} to idea number #{target_idea.id}"
      self.merged_to_idea.votes << vote
    end
  end
  
  def user_friendly_release_name
    "#{release.version} (#{release.release_status.description})" unless release.nil?
  end
  
  def watched? user
    watchers.include? user
  end
  
  private
  
  def self.add_criteria(condition_params, condition_string, values = nil)
    condition_params[0] += " and " if condition_params[0].length > 0
    condition_params[0] += condition_string
    condition_params += Array(values) unless values.nil?
    condition_params
  end
  
  # Create a vote, if possible, against a list of allocations
  def allocation_votes(allocations, user)
    # TODO: We probably want to add a flag to the allocations table to allow
    #       us to not have to iterate through every allocation to find one with
    #       open votes
    #       
    #  Loop through allocations looking for an open allocation, oldest first
    for allocation in allocations
      if allocation.available_quantity > 0
        allocation.votes.create(:user_id => user.id, :idea_id => id)
        return true
      end
    end
    # no allocations exist for this user
    return false
  end
end