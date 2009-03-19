require File.dirname(__FILE__) + '/../test_helper'
require 'comments_controller'

# Re-raise errors caught by the controller.
class CommentsController; def rescue_action(e) raise e end; end

class CommentsControllerTest < ActionController::TestCase 
  fixtures :comments, :users, :ideas, :forums, :topics

  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @comment_id = comments(:first_comment).id
    @idea_id = comments(:first_comment).idea_id
    @user_id = comments(:first_comment).user_id    
    @topic_id = comments(:topic_comment2).topic.id
    login_as 'allroles'
  end
  
  context "on GET to :preview" do
    setup { get :preview }
  end
  
  #  context "on GET to :show" do
  #    setup { get :show, :id => @comment_id }
  # 
  #    should_respond_with :success
  #    should_render_template :show
  #    should_not_set_the_flash
  #    should_assign_to :comment
  #  end
  
  def test_routing  
    assert_recognizes({:controller => 'products', :action => 'create'},
      :path => 'products', :method => :post)
  end

  context "on GET to :new with type of Idea" do
    setup { get :new, :id => @idea_id, :type => 'Idea' }

    should_respond_with :success
    should_render_template 'new'
    should_not_set_the_flash
    should_assign_to :comment
  end

  context "on GET to :new with type of Topic" do
    setup { get :new, :id => topics(:bug_topic1).id, :type => 'Topic' }

    should_respond_with :success
    should_render_template 'new'
    should_not_set_the_flash
    should_assign_to :comment
  end  

  context "on PUT to :update for idea" do
    setup { put :update, :id => @comment_id }
    
    should_respond_with :redirect
    should_set_the_flash_to(/updated/i)
  end

  context "on PUT to :update for topic" do
    setup { put :update, :id => comments(:topic_comment2).id }
    
    should_redirect_to "topic_path(@comment.topic)"
    should_respond_with :redirect
    should_set_the_flash_to(/updated/i)
  end

  context "on PUT to :update for topic with bad value" do
    setup { put :update, :id => comments(:topic_comment2).id, :comment => { :body => ""} }
    
    should_respond_with :success
    should_render_template :edit
    should_not_set_the_flash
    should_assign_to :comment
  end

  context "on POST to :endorse for comment" do
    setup { post :endorse, :id => comments(:topic_comment2).id }

    should_respond_with :redirect
    should_redirect_to "topic_path(@comment.topic, :anchor => @comment.id)"
    should_set_the_flash_to(/endorsed/i)
  end

  def test_destroy
    assert_nothing_raised {
      Comment.find(@comment_id)
    }

    delete :destroy, :id => @comment_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Comment.find(@comment_id)
    }
  end
end
