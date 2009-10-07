require File.join(File.dirname(__FILE__), 'spec_helper')

class User < ActiveRecord::Base
  model_stamper
end
  
describe UsersController, :type => :controller do
  fixtures :users
  
  before(:each) do
    @zeus = users(:zeus)
    @hera = users(:hera)
  end

  describe "update" do
    it "single request" do
      request.session[:user_id]  = 2
      post :update, :id => 2, :user => {:name => 'Different'}
      response.should be_success
      assigns["user"].name.should == 'Different'
      assigns["user"].updater.should == @hera
    end

    it "multiple request" do
      request.session[:user_id]  = 2
      get :edit, :id => 2
      response.should be_success
      
      request.session[:user_id]  = 1
      post :update, :id => 2, :user => {:name => 'Different Second'}
      response.should be_success
      assigns["user"].updater.should == @zeus
    end
  end


end
