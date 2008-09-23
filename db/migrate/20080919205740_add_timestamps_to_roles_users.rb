class AddTimestampsToRolesUsers < ActiveRecord::Migration
  def self.up
    change_column(:roles_users, :created_at, :datetime, :null => true)
    change_column(:forum_mediators, :created_at, :datetime, :null => true)
    change_column(:poll_user_responses, :created_at, :datetime, :null => true)
  end

  def self.down
  end
end
