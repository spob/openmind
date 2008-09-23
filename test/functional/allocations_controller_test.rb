require File.dirname(__FILE__) + '/../test_helper'
require 'allocations_controller'

# Re-raise errors caught by the controller.
class AllocationsController; def rescue_action(e) raise e end; end

class AllocationsControllerTest < Test::Unit::TestCase
  fixtures :allocations, :users, :enterprises

  def setup
    @controller = AllocationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = allocations(:user_allocation).id
    login_as 'allroles'
  end
  
  def test_routing  
    with_options :controller => 'allocations' do |test|
      test.assert_routing 'allocations', :action => 'index'
      test.assert_routing 'allocations/1', :action => 'show', :id => '1'
      test.assert_routing 'allocations/1/edit', :action => 'edit', :id => '1'
    end
    assert_recognizes({:controller => 'allocations', :action => 'create'},
      :path => 'allocations', :method => :post)
    assert_recognizes({:controller => 'allocations', :action => 'update', :id => "1"},
      :path => 'allocations/1', :method => :put)
    assert_recognizes({:controller => 'allocations', :action => 'destroy', :id => "1"},
      :path => 'allocations/1', :method => :delete)
    assert_recognizes({:controller => 'allocations', :action => 'export_import'},
      :path => 'allocations/export_import', :method => :get)
    assert_recognizes({:controller => 'allocations', :action => 'export'},
      :path => 'allocations/export', :method => :post)
    assert_recognizes({:controller => 'allocations', :action => 'import'},
      :path => 'allocations/import', :method => :post)
  end

  def test_index
    get :index

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:allocations)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:allocation)
    assert assigns(:allocation).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:allocation)
  end

  def test_create
    num_allocations = Allocation.count
    
    post :create, :allocation => {
      :allocation_type=> allocations(:user_allocation).class.to_s,
      :quantity => allocations(:user_allocation).quantity,
      :comments =>allocations(:user_allocation).comments,
      :expiration_date => allocations(:user_allocation).expiration_date,
      :user_id =>  allocations(:user_allocation).user_id
    }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_allocations + 1, Allocation.count
  end

  def test_create_enterprise_alloc_no_users
    post :create, :allocation => {
      :allocation_type=> "EnterpriseAllocation",
      :quantity => 10,
      :comments => "test",
      :enterprise_id =>  enterprises(:no_users).id
    }

    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:allocation)
    assert assigns(:allocation).valid?
  end

  def test_update
    put :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to allocations_path
  end

  def test_export_import_display
    assert_nothing_raised {
      get :export_import
    }
  end

  def test_destroy
    assert_nothing_raised {
      Allocation.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      get :export
    }
  end
  

  def test_destroy
    assert_nothing_raised {
      Allocation.find(@first_id)
    }
  end
end
