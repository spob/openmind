class UserIdeaRead < ActiveRecord::Base
  belongs_to :user
  belongs_to :idea
end
