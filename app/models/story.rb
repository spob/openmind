class Story < ActiveRecord::Base
  belongs_to :iteration
  has_many :tasks, :dependent => :destroy
  has_many :notes, :class_name => 'StoryNote', :foreign_key => "story_id", :dependent => :destroy

  validates_numericality_of :pivotal_identifier, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true
  validates_uniqueness_of :pivotal_identifier, :case_sensitive => false, :scope => :iteration_id
  validates_presence_of :story_type, :url, :status, :name, :pivotal_identifier

  named_scope :accepted,
              :conditions => {:status => "accepted"}
  named_scope :pushed,
              :conditions => {:status => "pushed"}
  named_scope :pointed,
              :conditions => ['points >= 0']
  named_scope :bugs_to_be_integrated,
      :conditions => "bug_integrated_to_ontime_at is not null and bug_integrated_to_pivotal_at is null and story_type = 'bug'"
  named_scope :conditional_pushed,
              lambda { |param| return {} if param.nil? or param == "Y"
              {:conditions => ["stories.status <> ?", "pushed"]}
              }
  named_scope :conditional_not_accepted,
              lambda { |param| return {} if param.nil? or param == "Y"
              {:conditions => ["status != 'accepted'"]}
              }


  def self.sort_by_status stories
    stories.sort_by do |s|
      case s.status
        when "accepted" then
          1000 + (s.sort ? s.sort : 0)
        when "delivered" then
          2000 + (s.sort ? s.sort : 0)
        when "finished" then
          3000 + (s.sort ? s.sort : 0)
        when "rejected" then
          4000 + (s.sort ? s.sort : 0)
        when "started" then
          5000 + (s.sort ? s.sort : 0)
        when "unstarted" then
          6000 + (s.sort ? s.sort : 0)
        when "pushed" then
          7000 + (s.sort ? s.sort : 0)
      end
    end
  end

  def parse_bug_number
    Story.parse_bug(self.name)
  end

  def self.parse_bug title
    if (title =~ /^D\d+/ix)
      /\d+/x.match(title).to_s.to_i
    end
  end
end
