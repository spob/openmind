class SerialNumberReleaseMap < ActiveRecord::Base
  belongs_to :serial_number
  belongs_to :release
  has_many :serial_number_release_map_histories
  has_one :last_action, :class_name => "SerialNumberReleaseMapHistory", :order => "id DESC"
  
  after_save :persist_history
  
  private
  
  def persist_history
    action = self.disabled_at ? "REMOVE" : "ADD"
    self.serial_number_release_map_histories.create!(:action => action) if self.last_action.try(:action) != action
  end  
end
