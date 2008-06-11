class CustomField < LookupCode
  
  def self.users_custom_boolean1
    field = 
      CustomField.find(:first, :conditions => "short_name = 'users_custom_boolean1'")
    field.description unless field.nil?
  end
end
