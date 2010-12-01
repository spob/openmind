class Forecast < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :user
  has_and_belongs_to_many :products

  validates_presence_of :enterprise, :user, :partner_representative, :account_name, :rbm, :account_exec,
                        :location, :stage, :product, :close_at, :amount
  validates_length_of :partner_representative, :maximum => 50
  validates_length_of :account_name, :maximum => 50
  validates_length_of :rbm, :maximum => 50, :allow_nil => true
  validates_length_of :account_exec, :maximum => 50, :allow_nil => true
  validates_length_of :location, :maximum => 50
  validates_length_of :stage, :maximum => 25, :allow_nil => true
  validates_length_of :product, :maximum => 50, :allow_nil => true
  validates_length_of :comments, :maximum => 150
  validates_numericality_of :amount, :greater_than => 0, :allow_nil => true


  named_scope :active, :conditions => ["deleted_at is null" ] 

  def self.stages
    {
    "Prospecting" => 1,
    "Qualification" => 2,
    "Needs Analysis" => 3,
    "Selected" => 4,
    "Committed/Order Pending" => 5,
    "Closed/Won" => 6,
    "Closed/Lost" => 7
  }
  end
end
