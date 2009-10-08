require File.join(File.dirname(__FILE__), 'spec_helper')

describe PostsController, :type => :controller do
  fixtures :people, :posts
  
  before(:each) do
    @delynn = people(:delynn)
    @nicole = people(:nicole)
    @first_post = posts(:first_post)
    @second_post = posts(:second_post)
  end

  describe "update" do
    it "single request" do
      request.session[:person_id]  = 1
      post :update, :id => 1, :post => {:title => 'Different'}
      response.should be_success
      assigns["post"].title.should == 'Different'
      assigns["post"].updater.should == @delynn
    end

    it "multiple request" do
      request.session[:person_id]  = 1
      get :edit, :id => 2
      response.should be_success
      
      request.session[:person_id]  = 2
      post :update, :id => 1, :post => {:title => 'Different Second'}
      response.should be_success
      assigns["post"].title.should == 'Different Second'
      assigns["post"].updater.should == @nicole

      request.session[:person_id]  = 1
      post :update, :id => 2, :post => {:title => 'Different'}
      assert_response :success
      assert_equal    'Different', assigns["post"].title
      assert_equal    @delynn, assigns["post"].updater
    end
  end
  
end
