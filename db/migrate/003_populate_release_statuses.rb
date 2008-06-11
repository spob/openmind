require 'active_record/fixtures'

class PopulateReleaseStatuses < ActiveRecord::Migration
  def self.up
    down
    
    directory = File.join(File.dirname(__FILE__), "seed_data")
    Fixtures.create_fixtures(directory, "lookup_codes")
  end

  def self.down
    LookupCode.delete_all 
  end
end
