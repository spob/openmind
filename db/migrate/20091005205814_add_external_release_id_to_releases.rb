class AddExternalReleaseIdToReleases < ActiveRecord::Migration
  def self.up
    change_table :releases do |t|
      t.string :external_release_id
    end
    add_index :releases, [:external_release_id], :unique => true
  end

  def self.down
    remove_index :releases, [:external_release_id]
    change_table :releases do |t|
      t.remove :external_release_id
    end
  end
end
