# 
# To change this template, choose Tools | Templates
# and open the template in the editor.


module SessionCleaner
  def self.clean
    	sql = ActiveRecord::Base.connection();
	sql.execute "SET autocommit=0";
	sql.begin_db_transaction
	sql.update "DELETE FROM sessions WHERE updated_at < '#{7.day.ago.to_s(:db)}'";
	sql.commit_db_transaction
  end
end
