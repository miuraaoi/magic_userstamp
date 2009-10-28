class MagicUserstampController < ApplicationController
  include MagicUserstamp::Controller

  protected
    def current_user
      User.find(session[:user_id])
    end
  #end
end
