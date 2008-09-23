require File.dirname(__FILE__) + '/../test_helper'
require 'products_controller'

# Re-raise errors caught by the controller.
class ProductsController; def rescue_action(e) raise e end; end

class ProductsControllerTest < Test::Unit::TestCase
  fixtures :products, :users

  def setup
    @controller = ProductsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = products(:producta).id
    login_as 'allroles'
  end
  
  def test_routing  
    with_options :controller => 'products' do |test|
      test.assert_routing 'products', :action => 'index'
      test.assert_routing 'products/1', :action => 'show', :id => '1'
      test.assert_routing 'products/1/edit', :action => 'edit', :id => '1'
    end
    assert_recognizes({:controller => 'products', :action => 'create'},
      :path => 'products', :method => :post)
    assert_recognizes({:controller => 'products', :action => 'update', :id => "1"},
      :path => 'products/1', :method => :put)
    assert_recognizes({:controller => 'products', :action => 'destroy', :id => "1"},
      :path => 'products/1', :method => :delete)
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil assigns(:products)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:product)
    assert assigns(:product).valid?
  end

  def test_create
    num_products = Product.count

    post :create, :product => { :name => "dummy", 
      :description => "description" }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_products + 1, Product.count
  end

  def test_create_duplicate
    post :create, :product => { :name => "proda", 
      :description => "description" }

    assert_response 200
    assert_template 'index'
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:product)
    assert assigns(:product).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_update_null_description
    product = products(:producta)
    product.description = nil
    put :update, { :id => product.id, :product => { :name => product.name, 
        :description => nil }}
    assert_response 200
    assert_template 'products/edit'
  end

  def test_destroy
    assert_nothing_raised {
      Product.find(@first_id)
    }

    delete :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Product.find(@first_id)
    }
  end
end
