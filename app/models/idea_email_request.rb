#    t.integer  "idea_id"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.datetime "sent_at"
#    t.text     "message"
#    t.string   "subject",                   :null => false
#    t.string   "to_email",                  :null => false
#    t.boolean  "cc_self"
#    t.integer  "user_id",                   :null => false
#    t.string   "type",       :limit => 100, :null => false
 
class IdeaEmailRequest < EmailRequest
  validates_presence_of :idea
  belongs_to :idea
  
  def self.email_idea request_id
    request = IdeaEmailRequest.find(request_id)
    EmailNotifier.deliver_idea_email_request(request.id)
    request.update_attribute(:sent_at, Time.zone.now)
  end
end
