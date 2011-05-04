class AddProjectIdToBug < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    change_table :bugs do |t|
      t.integer :project_id, :null => false
    end
    add_foreign_key(:bugs, :project_id, :projects)
  end

  def self.down
    remove_foreign_key(:bugs, :project_id)
    change_table :bugs do |t|
      t.remove :project_id
    end
  end
end
