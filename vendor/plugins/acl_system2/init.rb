require 'caboose/logic_parser'
require 'caboose/role_handler'
require 'caboose/access_control'

# 
 ActionController::Base.send :include, Caboose
 ActionController::Base.send :include, Caboose::AccessControl

