class Forecast < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :user
  belongs_to :region
  belongs_to :account_exec
  belongs_to :rbm
  has_and_belongs_to_many :products

  validates_presence_of :enterprise, :user, :partner_representative, :account_name, # :rbm_id, :account_exec_id,
                        :address1, :city, :country, :stage, :product, :close_at, :amount
  validates_length_of :partner_representative, :maximum => 50
  validates_length_of :account_name, :maximum => 50
  validates_length_of :state, :maximum => 2, :allow_nil => true
  validates_length_of :stage, :maximum => 25, :allow_nil => true
  validates_length_of :product, :maximum => 50, :allow_nil => true
  validates_length_of :comments, :maximum => 150
  validates_numericality_of :amount, :greater_than => 0, :allow_nil => true


  named_scope :active, :conditions => ["deleted_at is null" ]
  named_scope :export_sort, :order => "enterprise_id, close_at"

  def self.stages
    {
    "Prospecting" => 1,
    "Qualification" => 2,
    "Needs Analysis" => 3,
    "Selected" => 4,
    "Committed/Order Pending" => 5,
#    "Closed/Won" => 6,
    "Closed/Lost" => 7
  }
  end
end
