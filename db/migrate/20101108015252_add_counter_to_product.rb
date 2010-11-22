class AddCounterToProduct < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.integer :ideas_count, :default => 0
      t.integer :releases_count, :default => 0
    end

    Product.reset_column_information
    Product.all.each do |p|
      p.update_attribute :ideas_count, p.ideas.length
      p.update_attribute :releases_count, p.releases.length
    end

    change_table :comments do |t|
      t.integer :comment_attachments_count, :default => 0
    end

    Comment.reset_column_information
    Comment.all.each do |p|
      p.update_attribute :comment_attachments_count, p.comment_attachments.length
    end

    change_table :users do |t|
      t.integer :comments_count, :default => 0
    end

    User.reset_column_information
    User.all.each do |p|
      p.update_attribute :comments_count, p.topic_comments.length
    end
  end

  def self.down
    change_table :products do |t|
      t.remove :ideas_count
      t.remove :releases_count
    end

    change_table :comments do |t|
      t.remove :comment_attachments_count
    end

    change_table :users do |t|
      t.remove :comments_count
    end
  end
end
