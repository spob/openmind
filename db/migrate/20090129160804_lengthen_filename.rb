class LengthenFilename < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      # lengthen foreign keys
      t.change :filename, :string, :limit => 200
    end
  end

  def self.down
    for attachment in Attachment.find(:all)
      if attachment.filename.length > 50
        attachment.filename = attachment.filename.slice(1..50)
        attachment.save
      end
    end
    change_table :attachments do |t|
      # lengthen foreign keys
      t.change :filename, :string, :limit => 50
    end
  end
end
