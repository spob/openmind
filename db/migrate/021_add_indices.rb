class AddIndices < ActiveRecord::Migration
  def self.up
    # should no longer be necessary because of the creation of foreign keys
    #    add_index :allocations, :user_id, :unique => false
    #    add_index :allocations, :enterprise_id, :unique => false
    # 
    #    add_index :comments, :user_id, :unique => false
    #    add_index :comments, :idea_id, :unique => false
    # 
    #    add_index :ideas, :user_id, :unique => false
    #    add_index :ideas, :product_id, :unique => false
    #    add_index :ideas, :release_id, :unique => false
    #    add_index :ideas, :title, :unique => true
    # 
    #    add_index :releases, :product_id, :unique => false
    # 
    #    add_index :votes, :user_id, :unique => false
    #    add_index :votes, :allocation_id, :unique => false
    #    add_index :votes, :idea_id, :unique => false
  end

  def self.down
    #    remove_index :allocations, :user_id
    #    remove_index :allocations, :enterprise_id
    # 
    #    remove_index :comments, :user_id
    #    remove_index :comments, :idea_id
    # 
    #    remove_index :ideas, :user_id
    #    remove_index :ideas, :product_id
    #    remove_index :ideas, :release_id
    #    remove_index :ideas, :title
    # 
    #    remove_index :releases, :product_id
    # 
    #    remove_index :votes, :user_id
    #    remove_index :votes, :allocation_id
    #    remove_index :votes, :idea_id
  end
end
