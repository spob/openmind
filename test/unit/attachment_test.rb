#   t.column :filename, :string, :limit => 50, :null => false
#   t.column :description, :string, :limit => 200, :null => false
#   t.column :content_type, :string, :limit => 20, :null => false
#   t.column :size, :integer, :null => false
#   t.column :data, :binary, :null => false
require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  fixtures :users, :roles
  
  should_require_attributes :filename, :description, :content_type, :size
  should_belong_to :user
  
  context "testing list" do
    should "list attachments" do
      assert_nothing_raised {
        Attachment.list 1, 10
      }
    end
  end
  
  context "testing can delete" do
    setup { 
      @attachment = Attachment.new(:user => users(:bob))
    }
    
    should "allow delete" do
      assert @attachment.can_delete?(users(:allroles))
      @attachment.user = users(:bob)
      assert @attachment.can_delete?(users(:bob))
    end
    
    should "not allow delete" do
      assert !@attachment.can_delete?(users(:judy))
    end
  end
  
  context "testing image" do
    setup { @attachment = Attachment.new }
    
    should "indicate an image" do
      @attachment.content_type = 'image/gif'
      assert @attachment.image?
      
      @attachment.content_type = 'image/GIF'
      assert @attachment.image?
      
      @attachment.content_type = 'image/jpeg'
      assert @attachment.image?
      
      @attachment.content_type = 'image/png'
      assert @attachment.image?
      
      @attachment.content_type = 'image/tiff'
      assert @attachment.image?
    end
    
    should "not indicate an image" do
      @attachment.content_type = 'image/xxx'
      assert !@attachment.image?
    end
  end
end
