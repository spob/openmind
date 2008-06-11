class AddTimeZoneColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :time_zone, :string, :default => TimeZoneUtils.current_timezone.name
  end

  def self.down
    remove_column :users, :time_zone
  end
end
