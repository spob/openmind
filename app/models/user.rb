# == Schema Information
# Schema version: 20081021172636
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  first_name                :string(40)
#  last_name                 :string(40)
#  row_limit                 :integer(4)      default(10), not null
#  active                    :boolean(1)      default(TRUE), not null
#  lock_version              :integer(4)      default(0)
#  activation_code           :string(40)
#  activated_at              :datetime
#  last_message_read         :datetime
#  enterprise_id             :integer(4)      not null
#  time_zone                 :string(255)     default("Eastern Time (US & Canada)")
#  force_change_password     :boolean(1)      default(TRUE), not null
#  hide_contact_info         :boolean(1)      default(TRUE)
#  custom_boolean1           :boolean(1)
#  watch_on_vote             :boolean(1)      default(TRUE), not null
#  identity_url              :string(255)
#

require 'digest/sha1'

class User < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  ajaxful_rater
#  acts_as_solr :fields => [:email, :first_name, :last_name], 
#    :include => [:enterprise]
    
  define_index do
    indexes email, :sortable => true
    indexes first_name, :sortable => true
    indexes last_name, :sortable => true
    indexes enterprise(:name), :as => :enterprise, :sortable => true
    
    has created_at, updated_at
    set_property :delta => true
  end

  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessor :initial_allocation # to allow user to create an allocation at the
  # same time they create a user
  attr_protected :activated_at 

  validates_presence_of     :email, :row_limit, :last_name, :enterprise
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_email_format_of :email, :allow_nil => true
  validates_numericality_of :row_limit 
  validates_length_of       :first_name, :maximum => 40, :allow_nil => true
  validates_length_of       :last_name, :maximum => 40, :allow_nil => true
  validates_length_of       :activation_code, :maximum => 40, :allow_nil => true
  before_save :encrypt_password
  
  belongs_to :enterprise
  has_and_belongs_to_many :roles  
  # This collection is for watches
  has_and_belongs_to_many :watched_ideas, :join_table => 'watches', :class_name => 'Idea'
  has_and_belongs_to_many :forum_watches, :join_table => 'forum_watches', :class_name => 'Forum'
  has_and_belongs_to_many :watched_products, :join_table => 'products_watches', :class_name => 'Product'
  has_and_belongs_to_many :groups, :join_table => 'group_members', :class_name => 'Group'
  has_many :topic_watches
  # couldn't get through to work
  has_many :watched_topics, :class_name => 'Topic',
    :finder_sql => 'SELECT t.* ' +
    'from Topics AS t ' +
    'INNER JOIN topic_watches AS tw ON t.id = tw.topic_id ' +
    'WHERE tw.user_id = #{id} ' +
    'ORDER BY t.forum_id, t.updated_at DESC'
  has_and_belongs_to_many :poll_options, :join_table => 'poll_user_responses'
  has_and_belongs_to_many :mediated_forums, :join_table => 'forum_mediators', :class_name => 'Forum'
  
  has_one :last_logon, :class_name => "UserLogon", :order => "created_at DESC"
  has_many :user_logons, :order => "created_at DESC", :dependent => :destroy   
  has_many :ideas,:dependent => :destroy, :order => "id ASC"   
  has_many :allocations, :dependent => :destroy, :order => "created_at ASC"   
  #  has_many :active_allocations, :conditions => ["expiration_date > ?", Date.current.to_s(:db)],
  #    :order => "created_at ASCactive_allocations"
  # all votes by this user based only on user allocations
  has_many :votes, :through => :allocations, :order => "votes.id ASC"
  # all votes by this user regardless of allocation
  has_many :all_votes, :class_name => 'Vote', :foreign_key => "user_id", :order => "votes.id ASC"
  has_many :comments,:dependent => :destroy, :order => "id ASC"
  has_many :topic_comments,:dependent => :destroy, :order => "id ASC"
  has_many :user_idea_reads,:dependent => :destroy
  has_many :rates
  has_many :owned_topics, :class_name => 'Topic', :foreign_key => "owner_id"
  has_many :portal_orgs, :class_name => 'PortalUserOrgMap', :foreign_key => 'email', :primary_key => 'email'
  has_many :portal_reseller_orgs, :class_name => 'PortalUserOrgMap', :conditions => "org_type = 'R'", :foreign_key => 'email', :primary_key => 'email'
  has_many :portal_end_customer_orgs, :class_name => 'PortalUserOrgMap', :conditions => "org_type = 'E'", :foreign_key => 'email', :primary_key => 'email'
  
  before_create :make_activation_code

  
  named_scope :active,
    :conditions => [ "active = ?", true],
    :order => 'email asc'

  # imported users have both activated_at and activation_code as null
  named_scope :imported_users,
    :conditions => ["activated_at is null and activation_code is null" ]

  named_scope :sysadmins,
    :joins => [:roles],
    :conditions => {:active => 1, :roles => {:title => 'sysadmin'}},
    :order => :email

  named_scope :voters,
    :joins => [:roles],
    :conditions => {:active => 1, :roles => {:title => 'voter'}},
    :order => 'users.email'

  named_scope :mediators,
    :joins => [:roles],
    :conditions => {:active => 1, :roles => {:title => 'mediator'}},
    :order => 'users.email'

  named_scope :next,
    lambda{|email|{:conditions => ['email > ?', email],
      :order => 'email',
      :limit => 1}}

  named_scope :previous,
    lambda{|email|{:conditions => ['email < ?', email],
      :order => 'email desc',
      :limit => 1}}

  def self.row_limit_options
    [10, 25, 50, 100]
  end
  
  def sysadmin?
    roles.collect(&:title).include? 'sysadmin'
  end
  
  def prodmgr?
    roles.collect(&:title).include? 'prodmgr'
  end

  def voter?
    roles.collect(&:title).include? 'voter'
  end

  def allocmgr?
    roles.collect(&:title).include? 'allocmgr'
  end

  def mediator?
    roles.collect(&:title).include? 'mediator'
  end
  
  def user_logons_90_days
    user_logons.find(:all, :conditions => ['created_at > ?', (Time.zone.now - 60*60*24*90).to_s(:db)])
  end
  
  def last_logon_date
    last_logon.created_at unless last_logon.nil?
  end
  
  # Authenticates a user by their email and unencrypted password.  Returns the
  # user or nil.
  def self.authenticate(email, password)
    # hide records with a nil activated_at
    u = User.find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
    u && u.authenticated?(password) ? u : nil
  end
  
  def self.authenticate_otp(email, otp)
    # hide records with a nil activated_at
    u = User.find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
    u = u && u.one_time_password == otp ? u : nil
    u = u && !u.otp_expired? ? u : nil
    u.update_attributes!(:one_time_password => nil) if u
    u
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password) && enterprise.active && active && 
      !activated_at.nil?
  end

  def remember_token?
    remember_token_expires_at && Time.zone.now < remember_token_expires_at 
  end
  
  def login
    email
  end
  
  def login=(p_login)
    self.email = p_login
  end

  # These create and unset the fields required for remembering users between
  # browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def can_delete?
    ideas.empty? and allocations.empty? and comments.empty?
  end
  
  def available_user_votes
    if @available_user_votes.nil?
      @available_user_votes = 0
      for allocation in allocations.active
        @available_user_votes += allocation.quantity - allocation.votes.size
      end
    end
    @available_user_votes
  end
  
  def available_enterprise_votes
    if @available_enterprise_votes.nil?
      @available_enterprise_votes = 0
      for allocation in enterprise.allocations.active
        @available_enterprise_votes += allocation.quantity - allocation.votes.size
      end
    end
    @available_enterprise_votes
  end
  
  def available_votes
    available_user_votes + available_enterprise_votes
  end
    
  def self.list(page, per_page, start_filter, end_filter, ids)
    conditions = []
    unless start_filter == 'All'
      conditions << "email >= ? and email <= ?"
      conditions << start_filter
      conditions << end_filter
    end
    unless ids.nil?
      conditions << "id in (?)"
      conditions << ids
    end
    paginate :page => page, :order => 'email',
      :per_page => per_page, :include => 'enterprise',
      :conditions => conditions
  end
  
  def full_name
    full_name = ""
    if !self.first_name.nil?
      full_name << self.first_name
      full_name << " "
    end
    full_name << self.last_name
    full_name
  end
  
  def short_name
    return self.last_name if self.first_name.nil? or self.first_name.length == 0
    "#{self.first_name} #{self.last_name[0, 1]}"
  end
  
  def new_random_password
    self.salt = calc_salt
    self.password=  self.salt[0,6]
    self.password_confirmation = self.password
  end
  
  def new_otp
    self.one_time_password = APP_CONFIG['otp_expire_seconds'].to_i.from_now.xmlschema + '|' + Digest::SHA1.hexdigest("--#{calc_salt[0,6]}--#{Time.now.to_s}--")
  end
  
  require 'rexml/document'
  def otp_to_xml
    doc = REXML::Document.new
    root = doc.add_element "one_time_password"
    root.add_text self.one_time_password
    doc << REXML::XMLDecl.new(REXML::XMLDecl::DEFAULT_VERSION, REXML::XMLDecl::DEFAULT_ENCODING)
    doc.to_s
  end
  
  def otp_expired?
    return false if self.one_time_password.nil?
    return Time.xmlschema(self.one_time_password.split('|').first) < Time.now
  end
  
  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.zone.now
    self.activation_code = nil
    self.save!
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def display_name always_full=false
    return "#{self.short_name}" if (self.hide_contact_info and !always_full) or self.email.nil?
    "#{self.full_name} (#{self.email})"
  end
  
  def reset_password
    new_random_password
    self.activated_at = nil
    make_activation_code
    self.force_change_password = true
  end
  
  def unread_announcements?
    last_announcement = Announcement.find(:first, :order => "created_at DESC")
    return false if last_announcement.nil?
    return true if self.last_message_read.nil?
    self.last_message_read < last_announcement.created_at
  end
  
  def open_polls
    Poll.open_polls(self)
  end
  
  def watch_topic(topic)
    topic_watches.create(:topic => topic)
  end
  
  def can_view_portal?
    portal_enterprise_types.include?(self.enterprise.enterprise_type) && self.enterprise.view_portal
  end
  
  def can_specify_email_in_portal?
    portal_specify_email_enterprise_types.include? self.enterprise.enterprise_type
  end

  protected
  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.zone.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end
    
  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def validate
    errors.add(:row_limit, "should be at least 1 or greater") if row_limit.nil?  || row_limit < 1
  end

  def make_activation_code
    # special keyword SKIP will prevent the activation code from being created
    if self.activation_code == 'SKIP'
      self.activation_code = nil
    else
      self.activation_code = Digest::SHA1.hexdigest( Time.zone.now.to_s.split(//).sort_by {rand}.join )
    end
  end

  memoize :mediator?, :prodmgr?, :sysadmin?
  
  private
  
  def calc_salt
    Digest::SHA1.hexdigest("--#{Time.zone.now.to_s}--#{email}--")
  end
  
  def portal_enterprise_types
    # strip surrounding ()
    types = (APP_CONFIG['show_portal_for_enterprise_types'] || "").gsub(/^\s*\(|\)\s*$/, "").split(/,/) || [""]
    LookupCode.find(:all, :conditions => { :short_name => types, :code_type => 'EnterpriseType'})
  end
  
  def portal_specify_email_enterprise_types
    # strip surrounding ()
    types = (APP_CONFIG['allow_email_override_for_enterprise_types'] || "").gsub(/^\s*\(|\)\s*$/, "").split(/,/) || [""]
    LookupCode.find(:all, :conditions => { :short_name => types, :code_type => 'EnterpriseType'})
  end
end
