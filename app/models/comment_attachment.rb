# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class CommentAttachment < Attachment
  belongs_to :comment
  validates_presence_of :comment
end
