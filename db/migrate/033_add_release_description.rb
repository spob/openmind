class AddReleaseDescription < ActiveRecord::Migration
  def self.up
    add_column(:releases, :description, :string, :null => true)
    add_column(:releases, :release_date, :datetime, :null => true)
    add_column(:releases, :user_release_date, :string, :null => true)
    
    Release.reset_column_information
    
    Release.find(:all).each do |r|
      r.release_date = Time.zone.now
      r.user_release_date = r.release_date.strftime("%b %d, %Y")
      r.save
    end
    
    
    execute "ALTER TABLE releases MODIFY COLUMN description TEXT"
  end

  def self.down
    remove_column :releases, :description
    remove_column :releases, :release_date
    remove_column :releases, :user_release_date
  end
end
