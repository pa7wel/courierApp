class V1::RoutesController < ApplicationController
	def index
		@routes = Route.all
		
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