class AddTypeToComments < ActiveRecord::Migration
  def self.up
    add_column(:comments, :type, :string, :null => true)
    execute "update comments set type='IdeaComment'"
    change_column(:comments, :type, :string, :null => false)
  end

  def self.down
    remove_column :comments, :type
  end
end