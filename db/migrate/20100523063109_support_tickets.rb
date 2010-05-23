class SupportTickets < ActiveRecord::Migration
  def self.up
    create_table :support_tickets do |t|
      t.string :serial_number, :null => false
      t.string :ticket_number, :null => false
      t.datetime :opened_at, :null => false
      t.datetime :closed_at
      t.float :days_open
      t.string :priority
      t.string :status
      t.string :summary
      t.string :payment_type
      t.string :contact_person
      t.string :customer_name 
      t.string :customer_type
    end
    add_index :support_tickets, [:serial_number, :ticket_number], :unique => true
  end

  def self.down
    drop_table :support_tickets 
  end
end
