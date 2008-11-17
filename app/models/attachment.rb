#   t.column :filename, :string, :limit => 50, :null => false
#   t.column :description, :string, :limit => 200, :null => false
#   t.column :content_type, :string, :limit => 20, :null => false
#   t.column :size, :integer, :null => false
#   t.column :data, :binary, :null => false
require 'FileUtils'

class Attachment < ActiveRecord::Base
  validates_presence_of :filename, :description, :content_type, :size
  belongs_to :user
  has_one :thumbnail, :class_name => 'Attachment', 
    :foreign_key => :parent_attachment_id, :dependent => :delete
  # the attachment record for which this record is a thumbnail. If null, then
  # this image is not a thumbnail
  belongs_to :parent, :class_name => 'Attachment', :foreign_key => :parent_attachment_id

  def file=(incoming_file)
    self.filename = incoming_file.original_filename
    self.content_type = incoming_file.content_type
    self.size = incoming_file.size
    self.data = incoming_file.read
  end

  def filename=(new_filename)
    write_attribute("filename", sanitize_filename(new_filename))
  end

  def can_delete? user
    user.prodmgr? or user.sysadmin? or self.user == user
  end

  def self.list(page, per_page)
    paginate :page => page, 
      :conditions => 'parent_attachment_id IS NULL',
      :order => 'id DESC',
      :per_page => per_page
  end

  def image?
    content_type = self.content_type.downcase
    content_type == 'image/gif' or
      content_type == 'image/jpeg' or
      content_type == 'image/png' or
      content_type == 'image/tiff'
  end

  private
  def sanitize_filename(filename)
    return if filename.nil?
    # #get only the filename, not the whole path (from IE)
    just_filename = File.basename(filename)
    # #replace all non-alphanumeric, underscore or periods with underscores
    just_filename.gsub(/[^\w\.\-]/, '_')
  end

end
