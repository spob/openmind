# 
# string_utils.rb
# 
# Created on Jan 29, 2008, 3:34:37 PM
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class StringUtils
  # I create this method here because the pluralize that is used in screens is
  # only available from within the rhtml or helper file
  def self.pluralize count, noun
    return "#{count} #{noun}" if count == 1
    "#{count} #{ActiveSupport::Inflector.pluralize noun}"
  end
end
