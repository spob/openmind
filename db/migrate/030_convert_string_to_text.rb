# Bug in rails is preventing us from using text columns...this script does it
# using straight SQL
class ConvertStringToText < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE allocations MODIFY COLUMN comments TEXT"
    execute "ALTER TABLE announcements MODIFY COLUMN description TEXT"
    execute "ALTER TABLE comments MODIFY COLUMN body TEXT"
    execute "ALTER TABLE ideas MODIFY COLUMN description TEXT"
    execute "ALTER TABLE votes MODIFY COLUMN comments TEXT"
  end

  def self.down
    execute "ALTER TABLE allocations MODIFY COLUMN comments varchar(1000)"
    execute "ALTER TABLE announcements MODIFY COLUMN description varchar(1000)"
    execute "ALTER TABLE comments MODIFY COLUMN body varchar(1000)"
    execute "ALTER TABLE ideas MODIFY COLUMN description varchar(1000)"
    execute "ALTER TABLE votes MODIFY COLUMN comments varchar(1000)"
  end
end
