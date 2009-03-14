class AddPrivateToComments < ActiveRecord::Migration
  def self.up
    change_table :comments do |t|
      t.boolean :private, :default => false, :null => false
    end
  end

  def self.down
    change_table :comments do |t|
      t.remove :private
    end
  end
end
