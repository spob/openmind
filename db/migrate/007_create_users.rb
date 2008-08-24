class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :options => 'DEFAULT CHARSET=utf8', :force => true do |t|
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :first_name,                :string, :limit => 40
      t.column :last_name,                 :string, :limit => 40
      t.column :row_limit,                 :integer, :default => 10, :null => false 
      t.column :active,                    :boolean, :default => true, :null => false
      t.column :lock_version,              :integer, :default => 0
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :last_message_read,         :datetime
    end
    
    add_index :users, :email, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
