require File.dirname(__FILE__) + '/../test_helper'

class ReleaseTest < Test::Unit::TestCase
  fixtures :releases, :products, :lookup_codes
  
  def test_invalid_with_empty_attributes
    release = Release.new()
    assert !release.valid?
    assert release.errors.invalid?(:version)
  end
  
  def test_invalid_too_long
    release = Release.new(:version => "012345678901234567890x")
    assert !release.valid?
    assert_equal "is too long (maximum is 20 characters)", 
      release.errors.on(:version)
  end
  
  def test_version_ok
    release = Release.new(:version => "01234567890123456789")
    assert release.valid?
  end
  
  def test_valid_with_attributes
    release = Release.new(:version => "9999", 
      :release_status_id => lookup_codes(:release_status_controller_test).id, 
      :product_id => products(:producta).id)
    assert release.valid?
  end
end
