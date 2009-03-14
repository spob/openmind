class AttachmentEditedAt < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.datetime :edited_at
    end

    Attachment.reset_column_information
    for attachment in Attachment.find(:all)
      attachment.update_attribute(:edited_at, attachment.updated_at)
    end

    change_table :attachments do |t|
      t.change :edited_at, :datetime, :null => false
    end
  end

  def self.down
    change_table :attachments do |t|
      t.remove :edited_at
    end
  end
end
