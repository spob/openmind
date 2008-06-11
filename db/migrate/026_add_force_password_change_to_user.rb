class AddForcePasswordChangeToUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :force_change_password, :boolean, :default => true, :null => false)
    
    User.reset_column_information
    
    for user in User.find(:all)
      user.update_attribute(:force_change_password, false)
    end
  end

  def self.down
    remove_column :users, :force_change_password
  end
end