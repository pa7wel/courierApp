class V1::RoutesController < ApplicationController
  before_filter :authenticate_user!
  
	def index
		@routes = Route.where(:user_id => current_user.id)
		
		render json: @routes, status: :ok
	end

	def update  
    @route = Route.find(params[:id])
    
    @route.update(route_params)
    head :no_content
  end

  def route_params
      params.permit(:_json, :done, :id)
  end
end