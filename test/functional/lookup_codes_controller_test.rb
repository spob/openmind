require File.dirname(__FILE__) + '/../test_helper'
require 'lookup_codes_controller'

# Re-raise errors caught by the controller.
class LookupCodesController; def rescue_action(e) raise e end; end

class LookupCodesControllerTest < ActionController::TestCase 
  fixtures :lookup_codes, :users

  def setup
    @controller = LookupCodesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = lookup_codes(:release_status_controller_test).id
    login_as 'allroles'
  end
  
  def test_routing  
    with_options :controller => 'lookup_codes' do |test|
      test.assert_routing 'lookup_codes', :action => 'index'
      test.assert_routing 'lookup_codes/1', :action => 'show', :id => '1'
      test.assert_routing 'lookup_codes/1/edit', :action => 'edit', :id => '1'
    end
    assert_recognizes({:controller => 'lookup_codes', :action => 'create'},
      :path => 'lookup_codes', :method => :post)
    assert_recognizes({:controller => 'lookup_codes', :action => 'update', :id => "1"},
      :path => 'lookup_codes/1', :method => :put)
    assert_recognizes({:controller => 'lookup_codes', :action => 'destroy', :id => "1"},
      :path => 'lookup_codes/1', :method => :delete)
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:lookup_codes)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:lookup_code)
  end

  def test_create
    num_lookup_codes = LookupCode.count

    post :create, :lookup_code => {:short_name => "yyy",
      :description => "desc", :sort_value => 99,
      :code_type => "ReleaseStatus" }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_lookup_codes + 1, LookupCode.count
  end

  def test_create_duplicate
    post :create, :lookup_code => { 
      :short_name => "fooShortName1", :description => "description",
      :code_type => "ReleaseStatus" }

    assert_response 200
    assert_template 'lookup_codes/index'
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:lookup_code)
  end

  def test_update
    put :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    assert_nothing_raised {
      LookupCode.find(@first_id)
    }

    delete :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      LookupCode.find(@first_id)
    }
  end

  def test_update_null_description
    lookup_code = lookup_codes(:release_status_controller_test)
    lookup_code.description = nil
    put :update, { :id => lookup_code.id, 
      :lookup_code => { 
        :short_name => lookup_code.short_name,:description => nil }}
    assert_response 200
    assert_template 'lookup_codes/edit'
  end

  def test_update_duplicate
    lookup_code1 = lookup_codes(:release_status_controller_test)
    lookup_code2 = lookup_codes(:release_status_val2_test)
    put :update, { :id => lookup_code2.id, 
      :lookup_code => { 
        :short_name => lookup_code1.short_name,:description => "asdfas" }}
    assert_response 200
    assert_template 'lookup_codes/edit'
  end
end
