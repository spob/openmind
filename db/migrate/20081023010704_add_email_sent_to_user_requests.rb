class AddEmailSentToUserRequests < ActiveRecord::Migration
  def self.up
    change_table :user_requests do |t|
      t.datetime :email_sent
    end
  end

  def self.down
    change_table :user_requests do |t|
      t.remove :email_sent
    end
  end
end
