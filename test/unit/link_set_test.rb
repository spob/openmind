require File.dirname(__FILE__) + '/../test_helper'

class LinkSetTest < ActiveSupport::TestCase
  should_have_many :links, :dependent => :destroy
  should_have_many :forums
end
