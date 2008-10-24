class EmailRequest < ActiveRecord::Base
  validates_presence_of :to_email, :user, :subject
  belongs_to :user
end
