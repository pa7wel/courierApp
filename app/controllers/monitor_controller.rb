class MonitorController < ApplicationController
  def index
  	@users = User.all;
  end

  def view
  	@user_id = params[:id]
  	@user_to_monit = User.find(@user_id)
  	@position_gps = Location.where(:user_id => @user_id)
  	@users_current_route = Route.where(:user_id => @user_id)
  	
  end

  def params_user_id
      params.permit(:id)
  end

end
