# == Schema Information
# Schema version: 20081021172636
# 
# Table name: polls
# 
#  id           :integer(4)      not null, primary key
#  title        :string(200)     not null
#  close_date   :date            not null
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
#  active       :boolean(1)      not null
#  updated_at   :datetime        not null
# 

class Poll < ActiveRecord::Base
  after_update :save_options
  validates_presence_of :close_date, :title
  validates_uniqueness_of :title 
  validates_length_of :title, :maximum => 200
  
  before_create :create_unselectable_poll_option
  
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :enterprise_types
  has_many :poll_options,
    :dependent => :destroy,
    :conditions => { :selectable => true},
    :order => "poll_options.id ASC"
  
  has_many :poll_options_all,
    :class_name => 'PollOption', 
    :foreign_key => "poll_id",
    :dependent => :destroy,
    :order => "poll_options.id ASC"
  
  has_one :unselectable_poll_option,
    :class_name => 'PollOption', 
    :foreign_key => "poll_id",
    :dependent => :destroy,
    :conditions => { :selectable => false}
  
  def can_delete?
    total_responses == 0 and !active
  end
  
  def self.list(page, include_unpublished, per_page, user)
    page = 1 if page.nil?
    @entries = WillPaginate::Collection.create(page, per_page) do |pager|
      result = Poll.find(:all, 
        :limit => pager.per_page, 
        :offset => pager.offset, 
        :conditions => [ "active = 1 or ? = 1", include_unpublished],
        :order => 'close_date DESC').find_all{|poll| poll.can_see? user}
      # inject the result array into the paginated collection:
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = 
          Poll.find(:all, 
          :conditions => [ "active = 1 or ? = 1", include_unpublished]).size
      end
    end
    
    #    paginate :page => page,
    #      :conditions => [ "active = 1 or ? = 1", include_unpublished],
    #      :order => 'close_date DESC',
    #      :per_page => per_page
  end
  
  def create_unselectable_poll_option
    poll_options << PollOption.new(:description => 'Unselectable', :selectable => false)
  end
  
  def option_attributes=(option_attributes)
    option_attributes.each do |attributes|
      if attributes[:id].blank?
        poll_options.build(attributes)
      else
        option = poll_options.detect { |o| o.id == attributes[:id].to_i }
        option.attributes = attributes
      end
    end
  end
  
  def taken_survey?(user)
    !user_responses.index(user).nil?
  end
  
  def user_responses
    responses = []
    for poll_option in poll_options_all
      responses << poll_option.user_responses
    end
    responses.flatten
  end
  
  def save_options
    poll_options.each do |o|
      if o.should_destroy?
        o.destroy
      else
        o.save(false)
      end
    end
  end
  
  def total_responses
    count = 0
    for option in poll_options
      count += option.user_responses.size
    end
    count
  end
  
  def self.open_polls(user)
    sql = 
      <<-endsql
        SELECT *
        FROM polls AS p
        WHERE p.active = 1
          AND p.close_date >= curdate()
          AND NOT EXISTS
          (SELECT null
          FROM poll_options AS po INNER JOIN poll_user_responses AS pur
          ON po.id = pur.poll_option_id
          WHERE pur.user_id = ?
            AND po.poll_id = p.id)
        ORDER BY p.created_at
    endsql
    Poll.find_by_sql([sql, user.id])
  end
  
  def can_see? user
    (user != :false and user.prodmgr?) or can_take? user
  end
  
  def can_take? user
    (((groups.empty? and enterprise_types.empty?) or 
          !groups.select{|group| group.users.include? user}.empty? or
          !enterprise_types.select{|enterprise_type| enterprise_type.users.include? user}.empty?) and active)
  end
end
