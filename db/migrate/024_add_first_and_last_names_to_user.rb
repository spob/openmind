class AddFirstAndLastNamesToUser < ActiveRecord::Migration
  def self.up
    # Moved logic into the create script RBS
    #    add_column(:users, :first_name, :string, :null => true)
    #    add_column(:users, :last_name, :string, :null => true)
    #    User.reset_column_information
    #    
    #    for user in User.find(:all)
    #      user.update_attribute(:last_name, user.email)
    #    end
    #    change_column(:users, :last_name, :string, :null => false)
  end

  def self.down
    #    remove_column :users, :first_name
    #    remove_column :users, :last_name
  end
end
