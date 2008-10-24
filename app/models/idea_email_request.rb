# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class IdeaEmailRequest < EmailRequest
  validates_presence_of :idea
  belongs_to :idea
  
  def self.email_idea request_id
    request = IdeaEmailRequest.find(request_id)
    EmailNotifier.deliver_idea_email_request(request.id)
    request.update_attribute(:sent_at, Time.zone.now)
  end
end
