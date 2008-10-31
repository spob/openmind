class AddEnterpriseTypeToUserRequest < ActiveRecord::Migration
  def self.up
    change_table :user_requests do |t|
      t.references :enterprise_type, :null => true
    end
  end

  def self.down
    change_table :user_requests do |t|
      t.remove :enterprise_type_id
    end
  end
end
