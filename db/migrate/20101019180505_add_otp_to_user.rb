class AddOtpToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :one_time_password
    end
  end
  
  def self.down
    change_table :users do |t|
      t.remove :one_time_password
    end
  end
end
