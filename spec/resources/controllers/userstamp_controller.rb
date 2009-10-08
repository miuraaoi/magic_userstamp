class UserstampController < ApplicationController
  include Userstamp::Controller

  protected
    def current_user
      User.find(session[:user_id])
    end
  #end
end
