class UpdateReleaseIndex < ActiveRecord::Migration
  def self.up
    remove_index :releases, :version
    add_index :releases, [:product_id, :version], :unique => true
  end

  def self.down
  end
end
