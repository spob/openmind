class CreateRates < ActiveRecord::Migration
  def self.up
    create_table :rates, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user
      t.references :rateable, :polymorphic => true
      t.integer :stars
      t.string :dimension

      t.timestamps
    end
    
    add_index :rates, :user_id
    add_index :rates, :rateable_id
  end

  def self.down
    drop_table :rates
  end
end
