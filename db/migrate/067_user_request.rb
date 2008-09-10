class UserRequest < ActiveRecord::Migration
  def self.up
    create_table :user_requests, :options => 'DEFAULT CHARSET=utf8', :force => true do |t|
      t.column "email",                     :string,            :null => false
      t.column "created_at",                :datetime
      t.column "updated_at",                :datetime
      t.column "first_name",                :string
      t.column "last_name",                 :string,            :null => false
      t.column "lock_version",              :integer,           :default => 0
      t.column "enterprise_name",           :string,            :null => false
      t.column "enterprise_id",             :integer,           :null => true
      t.column "initial_enterprise_allocation",  :integer, :default => 0, :null => false
      t.column "initial_user_allocation",   :integer, :default => 0, :null => false
      t.column "time_zone",                 :string,            :null => false
      t.column "status",                    :string,            :null => false, :limit => 10
    end
    add_index "user_requests", ["email"], :unique => false
  end

  def self.down
    drop_table :user_requests
  end
end
