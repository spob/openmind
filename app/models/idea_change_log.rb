class IdeaChangeLog < ActiveRecord::Base
  belongs_to :idea
  belongs_to :user
end
