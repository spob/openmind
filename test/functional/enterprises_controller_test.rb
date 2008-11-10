require File.dirname(__FILE__) + '/../test_helper'
require 'enterprises_controller'

# Re-raise errors caught by the controller.
class EnterprisesController; def rescue_action(e) raise e end; end

class EnterprisesControllerTest < Test::Unit::TestCase
  fixtures :enterprises, :users
  
  def setup
    @controller = EnterprisesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @enterprise = Enterprise.find(:first, :order => 'RAND()')
    login_as 'allroles'
  end
  
  def test_routing  
    with_options :controller => 'enterprises' do |test|
      test.assert_routing 'enterprises', :action => 'index'
      test.assert_routing 'enterprises/1', :action => 'show', :id => '1'
      test.assert_routing 'enterprises/1/edit', :action => 'edit', :id => '1'
    end
    assert_recognizes({:controller => 'enterprises', :action => 'create'},
      :path => 'enterprises', :method => :post)
    assert_recognizes({:controller => 'enterprises', :action => 'update', :id => "1"},
      :path => 'enterprises/1', :method => :put)
    assert_recognizes({:controller => 'enterprises', :action => 'destroy', :id => "1"},
      :path => 'enterprises/1', :method => :delete)
  end

  def test_should_know_index
    get :index

    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:enterprises)
  end

  def test_index
    get :index

    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:enterprises)
  end  
  
  def test_should_know_show
    get :show, :id => @enterprise

    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:enterprise)
    assigns(:enterprise).errors.each{|attr,msg| puts ":::::::::::::::::::::: #{attr} - #{msg}"}
    #    assert assigns(:enterprise).valid?
  end
  
  def test_should_know_create
    post :create, :enterprise => { :name => "dummy", :active => "true" }    

    assert !assigns(:enterprise).new_record?
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_not_nil flash[:notice]    
    assigns(:enterprise).errors.each{|attr,msg| puts "#{attr} - #{msg}"}
    assert_not_nil assigns(:enterprise)
  end  

  def test_should_reject_missing_enterprise_attribute
    post :create, :enterprise => { :active => 'true' }
    assert assigns(:enterprise).errors.on(:name)
  end

  def test_create_duplicate
    post :create, :enterprise => { :name => "Enterprise1", :active => "true" }

    assert_response 200
    assert_template 'enterprises/index'
  end
  
  def test_edit
    get :edit, :id => @enterprise, :enterprise => { :active => true }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:enterprise)
    assigns(:enterprise).errors.each{|attr,msg| puts ":::::::::::::::::::::: #{attr} - #{msg}"}
    assert assigns(:enterprise).valid?
  end
  
  def test_update
    put :update, :id => @enterprise, :enterprise => { :active => :true }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @enterprise
  end
  
  def test_destroy
    assert_nothing_raised { Enterprise.find(@enterprise) }

    delete :destroy, :id => @enterprise
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_raise(ActiveRecord::RecordNotFound) { Enterprise.find(@enterprise) }
  end
end