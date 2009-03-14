class AddRatingCacheColumn < ActiveRecord::Migration
  def self.up
    add_column :topics, :rating_average, :decimal, :default => 0
  end

  def self.down
    remove_column :topics, :rating_average
  end
end