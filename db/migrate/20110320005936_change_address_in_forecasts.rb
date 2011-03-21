class ChangeAddressInForecasts < ActiveRecord::Migration
  def self.up
    change_table :forecasts do |t|
      t.string :address1, :null => true #false
      t.string :address2, :null => true
      t.string :city, :null => true #false
      t.string :state, :null => true
      t.string :postal_code, :null => true
      t.string :country, :limit => 2, :null => true #false
    end

    Forecast.reset_column_information

    Forecast.all.each do |f|
      f.address1 = f.location
      f.city = 'XX'
      f.country = 'XX'
      f.save!
    end

    change_table :forecasts do |t|
      t.change :address1, :string, :null => false
      t.change :city, :string, :null => false
      t.change :country, :string, :null => false
      t.remove :location
    end
  end

  def self.down
    change_table :forecasts do |t|
      t.string :location, :null => true
    end

    Forecast.reset_column_information

    Forecast.all.each do |f|
      f.location = f.address1
      f.save!
    end

    change_table :forecasts do |t|
      t.remove :address1
      t.remove :address2
      t.remove :city
      t.remove :state
      t.remove :postal_code
      t.remove :country
      t.change :location, :string, :null => false
    end
  end
end
