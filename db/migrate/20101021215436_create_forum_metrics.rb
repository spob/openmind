require "migration_helpers"

class CreateForumMetrics < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :forum_metrics do |t|
      t.references :enterprise, :null => false
      t.integer :open_count, :null => false
      t.decimal :days_pending, :null => false, :precision => 5, :scale => 1
      t.date    :as_of, :null => false
      t.timestamps
    end
    add_foreign_key(:forum_metrics, :enterprise_id, :enterprises)
    add_index :forum_metrics, [:as_of, :enterprise_id], :unique => true
  end

  def self.down
    remove_foreign_key(:forum_metrics, :enterprise_id)
    drop_table :forum_metrics
  end
end
