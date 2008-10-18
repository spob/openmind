class AddEnterpriseId < ActiveRecord::Migration
  def self.up
    change_table :enterprises do |t|
      t.references :enterprise_type, :null => true
    end
  end

  def self.down
    change_table :enterprises do |t|
      t.remove :enterprise_type_id
    end
  end
end
