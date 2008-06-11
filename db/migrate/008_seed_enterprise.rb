class SeedEnterprise < ActiveRecord::Migration
  @companyName = "Main Company"
  
  def self.up
    Enterprise.create(:name => @companyName)
  end

  def self.down
   # Enterprise.find_by_name(@companyName).destroy
  end
end
