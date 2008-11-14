require File.dirname(__FILE__) + '/../test_helper'

class ProductTest < Test::Unit::TestCase
  fixtures :products, :lookup_codes

  should_have_and_belong_to_many :watchers
  
  def test_invalid_with_empty_attributes
    product = Product.new(:active => nil)
    assert !product.valid?
    assert product.errors.invalid?(:name)
    assert product.errors.invalid?(:description)
  end
  
  def test_invalid_too_long
    product = Product.new(:name => "0123456789001234567890012345678901", 
      :description => "description", 
      :active => true)
    assert !product.valid?
    assert_equal "is too long (maximum is 30 characters)", 
      product.errors.on(:name)
  end
  
  def test_valid_with_attributes
    product = Product.new(:name => "test", :description => "description", 
      :active => true)
    assert product.valid?
  end
  
  def test_active_default
    product = Product.new
    assert product.active
  end
  
  def test_uniqueness
    product2 = Product.new(:name => "proda", :description => "description")
    assert !product2.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], 
      product2.errors.on(:name)
  end
  
  def test_cascading_delete
    x = LookupCode.find(:all)
    product = Product.create(:name => "cascade", :description => "description")
    release = Release.new(:version => "999", 
      :release_status_id => ReleaseStatus.find(:first).id)
    product.releases << release
    product.save
    
    pid = product.id
    rid = release.id
    
    assert_nothing_raised { Product.find(pid) }
    assert_nothing_raised { Release.find(rid) }
    
    product.destroy
    
    assert_raise(ActiveRecord::RecordNotFound) { Product.find(pid) }
    assert_raise(ActiveRecord::RecordNotFound) { Release.find(rid) }
  end
end
