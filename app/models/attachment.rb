#    t.string   "filename",             :limit => 200,                          :null => false
#    t.string   "description",          :limit => 200,                          :null => false
#    t.string   "content_type",         :limit => 100,                          :null => false
#    t.integer  "user_id",                                                      :null => false
#    t.integer  "comment_id"
#    t.integer  "parent_attachment_id"
#    t.integer  "size",                                                         :null => false
#    t.binary   "data",                 :limit => 2147483647
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.boolean  "public",                                     :default => true, :null => false
#    t.integer  "downloads",                                  :default => 0,    :null => false
#    t.string   "alias",                :limit => 40
require 'fileutils'
require 'RMagick'

class Attachment < ActiveRecord::Base
  include Magick
  after_create :create_thumbnail
  before_update :before_update
  before_save :before_save
#  acts_as_solr :fields => [:filename, :alias, :description, {:size => :integer}],  :if => proc{|a| a.parent.nil?}
  define_index do
    indexes filename, :sortable => true
    indexes :alias, :sortable => true
    indexes description, :sortable => true
    
    has created_at, updated_at
    set_property :delta => true
  end
  
  validates_presence_of :filename, :description, :content_type, :size
  validates_length_of :filename, :maximum => 200
  validates_length_of :alias, :maximum => 40, :allow_nil => true
  validates_uniqueness_of :alias, :case_sensitive => false, 
    :allow_nil => true, :allow_blank => true
  belongs_to :user
  has_one :thumbnail, :class_name => 'Attachment', 
    :foreign_key => :parent_attachment_id, :dependent => :delete
  # the attachment record for which this record is a thumbnail. If null, then
  # this image is not a thumbnail
  belongs_to :parent, :class_name => 'Attachment', :foreign_key => :parent_attachment_id
  has_and_belongs_to_many :enterprise_types
  has_and_belongs_to_many :groups
  attr_accessor :confirm_alias

  def file=(incoming_file)
    self.filename = incoming_file.original_filename
    self.content_type = incoming_file.content_type
    self.size = incoming_file.size
    self.data = incoming_file.read
  end

  def filename=(new_filename)
    write_attribute("filename", sanitize_filename(new_filename))
  end

  def can_see? user
    return true if self.public
    return false if user == :false or user.nil?
    return true if user.mediator?
    (self.enterprise_types.empty? and self.groups.empty?) or 
      self.enterprise_types.include? user.enterprise.enterprise_type or
      !self.groups.select{|group| group.users.include? user}.empty?
  end

  def can_delete? user
    user.prodmgr? or user.sysadmin? or self.user == user
  end

  def self.list(page, per_page, ids=nil)
    conditions = {}
    conditions[:parent_attachment_id] = nil
    unless ids.nil?
      conditions[:id] = ids
    end
    paginate :page => page,
      :select => "id, filename, description, content_type, user_id, comment_id, parent_attachment_id, size, created_at, updated_at, public, downloads, alias",
      :conditions => conditions,
      :order => 'id DESC',
      :per_page => per_page
  end

  @@content_types = [
    'image/gif',
    'image/jpeg',
    'image/pjpeg',
    'image/bmp',
    'image/png',
    'image/x-png',
    'image/tiff'
  ]

  def image?
    content_type = self.content_type.downcase
    for ctype in @@content_types
      return true if ctype == content_type
    end
    #    logger.error "================= content type for update: #{content_type}"
    false
  end

  private
  def sanitize_filename(filename)
    return if filename.nil?
    # #get only the filename, not the whole path (from IE)
    just_filename = File.basename(filename)
    # #replace all non-alphanumeric, underscore or periods with underscores
    just_filename.gsub(/[^\w\.\-]/, '_')
  end

  def create_thumbnail
    # if a thumbnail, do nothing...avoid infinite recursion
    return unless parent.nil?
    
    thumbnail_data = gen_thumbnail_image(64, 64)
    unless thumbnail_data.nil?
      thumbnail_image = Attachment.new(:user => self.user, 
        :filename => "thumbnail-#{self.filename}",
        :description => "Thumbnail: #{self.description}",
        :data => thumbnail_data,
        :parent => self,
        :content_type => self.content_type,
        :size => thumbnail_data.size,
        :edited_at => Time.zone.now)
      thumbnail_image.public = self.public
      thumbnail_image.save!
    end
  end

  def before_update
    # if a thumbnail, do nothing...avoid infinite recursion
    return unless self.parent.nil?

    #won't have a thumbnail if not an image'
    unless self.thumbnail.nil?
      self.thumbnail.public = self.public
      self.thumbnail.save!
    end
  end
  
  def before_save
    self.alias = self.alias.try(:strip)
    self.filename = self.filename.try(:strip)
    self.description = self.description.try(:strip)
  end

  def gen_thumbnail_image width=100, height=100
    if self.image?
      img = Magick::Image.from_blob(self.data).first
      rows, cols = img.rows, img.columns
      
      # thumbnail is larger than image...return image
      return self.data if rows < height and cols < width

      source_aspect = cols.to_f / rows
      target_aspect = width.to_f / height
      thumbnail_wider = target_aspect > source_aspect

      factor = thumbnail_wider ? width.to_f / cols : height.to_f / rows
      img.thumbnail!(factor)
      img.crop!(CenterGravity, width, height)
      img.to_blob
    end
  end
end
