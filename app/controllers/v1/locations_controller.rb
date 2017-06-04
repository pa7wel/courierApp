class V1::LocationsController < ApplicationController
  before_filter :authenticate_user!
  
	def index
		@locations = Location.all
		
		render json: @locations, status: :ok
	end

	def create
    
    @location = Location.new(location_params)
    @location.user = current_user

    if @location.save
      render json: @location, status: :ok
    else
      head(:unauthorized)
    end

  end

  def location_params
      params.permit(:longitude, :latitude)
  end
end