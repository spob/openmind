class AddReleaseNotesToRelease < ActiveRecord::Migration
  def self.up
    change_table :releases do |t|
      t.string :release_notes
    end
  end

  def self.down
    change_table :releases do |t|
      t.remove :release_notes
    end
  end
end
