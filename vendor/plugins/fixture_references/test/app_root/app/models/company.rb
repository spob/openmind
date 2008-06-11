class Company < ActiveRecord::Base
  belongs_to  :parent_company,
                :class_name => 'Company',
                :foreign_key => 'parent_company_id'
end