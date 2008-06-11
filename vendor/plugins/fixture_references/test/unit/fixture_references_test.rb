require File.dirname(__FILE__) + '/../test_helper'

class FixtureReferencesTest < Test::Unit::TestCase
  def setup
    Fixtures.all_loaded_fixtures = {}
    Fixtures.all_partially_loaded_fixtures = {}
  end
  
  def test_should_set_fixture_path_when_fixtures_are_created
    Fixtures.create_fixtures("#{RAILS_ROOT}/../fixtures/", 'employees')
    assert_equal "#{RAILS_ROOT}/../fixtures/", Fixtures.fixture_path
  end
  
  def test_all_load_fixtures_should_be_empty
    assert Fixtures.all_loaded_fixtures.empty?
  end
  
  def test_all_partially_loaded_fixtures_should_be_empty
    assert Fixtures.all_partially_loaded_fixtures.empty?
  end
  
  def test_should_load_unidirectionally_referenced_fixtures
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    assert_instance_of Fixtures, Fixtures.all_loaded_fixtures['employees']
  end
  
  def test_should_not_partially_load_unidirectionally_referenced_fixtures
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    assert_nil Fixtures.all_partially_loaded_fixtures['employees']
  end
  
  def test_should_cache_unidirectionally_loaded_fixtures
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    employee_fixtures = Fixtures.all_loaded_fixtures['employees']
    
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    assert_same employee_fixtures, Fixtures.all_loaded_fixtures['employees']
  end
  
  def test_should_load_bidirectionally_referenced_fixtures
    Fixtures.new(ActiveRecord::Base.connection, 'companies', nil, "#{Fixtures.fixture_path}/companies")
    assert_instance_of Fixtures, Fixtures.all_loaded_fixtures['companies']
  end
  
  def test_should_partially_load_bidirectionally_referenced_fixtures
    Fixtures.new(ActiveRecord::Base.connection, 'companies', nil, "#{Fixtures.fixture_path}/companies")
    assert_instance_of Fixtures, Fixtures.all_partially_loaded_fixtures['companies']
    assert_not_equal Fixtures.all_loaded_fixtures['companies'], Fixtures.all_partially_loaded_fixtures['companies']
  end
  
  def test_should_use_nil_for_referenced_attributes_in_partially_loaded_fixtures
    Fixtures.new(ActiveRecord::Base.connection, 'companies', nil, "#{Fixtures.fixture_path}/companies")
    fixtures = Fixtures.all_partially_loaded_fixtures['companies']
    assert_nil fixtures['cnn']['parent_company_id']
  end
  
  def test_should_cache_bidirectionally_loaded_fixtures
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:companies)
    company_fixtures = Fixtures.all_loaded_fixtures['companies']
    partial_company_fixtures = Fixtures.all_partially_loaded_fixtures['companies']
    
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:companies)
    assert_same company_fixtures, Fixtures.all_loaded_fixtures['companies']
    assert_same partial_company_fixtures, Fixtures.all_partially_loaded_fixtures['companies']
  end
  
  def test_should_raise_exception_if_fixture_not_found
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    assert_raise(StandardError) {fixtures.employees(:invalid_employee_name)}
  end
  
  def test_should_include_fixture_information_in_fixture_not_found_exception
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    
    begin
      fixtures.employees(:invalid_employee_name)
    rescue StandardError => fixture_error
      assert_equal "No fixture with name 'invalid_employee_name' found for table 'employees'", fixture_error.message      
    end
  end
  
  def test_should_raise_exception_if_attribute_not_found
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    assert_raise(StandardError) {fixtures.employees(:bob, 'invalid_attribute')}
  end
  
  def test_should_include_fixture_information_in_attribute_not_found_exception
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    
    begin
      fixtures.employees(:bob, 'invalid_attribute')
    rescue StandardError => fixture_error
      assert_equal "No attribute with name 'invalid_attribute' found for fixture 'bob' in table 'employees'", fixture_error.message      
    end
  end
  
  def test_should_use_id_for_default_attribute
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    assert_equal 1, fixtures.employees(:bob)
  end
  
  def test_should_allow_custom_attributes_to_be_accessed
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'empty', nil, "#{Fixtures.fixture_path}/empty")
    fixtures.fixtures(:employees)
    assert_equal 'Bob', fixtures.employees(:bob, 'name')
  end
  
  def test_unidirectional_references
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'departments', nil, "#{Fixtures.fixture_path}/departments")
    assert_equal 1, fixtures['packaging']['id']
    assert_equal 1, fixtures['packaging']['manager_id']
    assert_equal 2, fixtures['quality_assurance']['id']
    assert_equal 2, fixtures['quality_assurance']['manager_id']
    assert_equal 3, fixtures['marketing']['id']
    assert_equal 3, fixtures['marketing']['manager_id']
  end
  
  def test_bidirectional_references
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'companies', nil, "#{Fixtures.fixture_path}/companies")
    assert_equal 1, fixtures['time_warner']['id']
    assert_equal 2, fixtures['cnn']['id']
    assert_equal 1, fixtures['cnn']['parent_company_id']
  end
  
  def test_multiple_references
    fixtures = Fixtures.new(ActiveRecord::Base.connection, 'departments_employees', nil, "#{Fixtures.fixture_path}/departments_employees")
    
    # Packaging
    assert_equal 1, fixtures['packaging_manager']['department_id']
    assert_equal 1, fixtures['packaging_manager']['employee_id']
    assert_equal 5, fixtures['packaging_will']['employee_id']
    assert_equal 6, fixtures['packaging_kevin']['employee_id']
    
    # Quality Assurance
    assert_equal 2, fixtures['quality_assurance_manager']['department_id']
    assert_equal 2, fixtures['quality_assurance_manager']['employee_id']
    assert_equal 4, fixtures['quality_assurance_ryan']['employee_id']
    assert_equal 5, fixtures['quality_assurance_will']['employee_id']
    
    # Marketing
    assert_equal 3, fixtures['marketing_manager']['department_id']
    assert_equal 3, fixtures['marketing_manager']['employee_id']
    assert_equal 6, fixtures['marketing_kevin']['employee_id']
    assert_equal 4, fixtures['marketing_ryan']['employee_id']
  end
  
  def test_create_fixtures
    Fixtures.create_fixtures("#{RAILS_ROOT}/../fixtures/", 'employees')
    assert_equal 6, Employee.count
    
    Fixtures.create_fixtures("#{RAILS_ROOT}/../fixtures", 'departments')
    assert_equal 3, Department.count
    
    assert_equal Employee.find_by_name('Bob'), Department.find_by_name('Packaging').manager
    assert_equal Employee.find_by_name('Joe'), Department.find_by_name('Quality Assurance').manager
    assert_equal Employee.find_by_name('Jane'), Department.find_by_name('Marketing').manager
  end
end
