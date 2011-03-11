require "migration_helpers"

class CreateStoryNotes < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :story_notes do |t|
      t.integer :pivotal_identifier, :null => false
      t.integer :defect_id, :null => false
      t.datetime :noted_at, :null => false
      t.text :comment, :null => false
      t.string :author, :null => false
      t.references :story, :null => false
      t.datetime :processed_at
      t.timestamps
    end
    add_foreign_key(:story_notes, :story_id, :stories)
    add_index :story_notes, [:pivotal_identifier], :unique => true


    change_table :projects do |t|
      t.integer :max_note_id, :null => false, :default => 0
    end
  end

  def self.down
    remove_foreign_key(:story_notes, :story_id)
    drop_table :story_notes

    change_table :projects do |t|
      t.remove :max_note_id
    end
  end
end
