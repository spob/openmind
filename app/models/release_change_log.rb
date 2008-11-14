#    t.integer  "release_id",   :null => false
#    t.integer  "user_id",      :null => false
#    t.text     "message",      :null => false
#    t.datetime "processed_at"
#    t.datetime "created_at"
#    t.datetime "updated_at"

class ReleaseChangeLog < ActiveRecord::Base
  belongs_to :release
  belongs_to :user
  
  validates_presence_of :message
end
