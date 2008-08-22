class AddCommentsColumnToVote < ActiveRecord::Migration
  def self.up
    add_column(:votes, :comments, :string, :null => true, :option => 'charset utf8')
  end

  def self.down
    remove_column :votes, :comments
  end
end
