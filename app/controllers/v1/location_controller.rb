class V1::LocationController < ApplicationController
	def index
		@locations = Location.all
		
		render json: @locations, status: :ok
	end

	def create
    pry.binding
    @location = Location.new(location_params)
   
    
    @location.save

  end

  def location_params
      params.permit(:longitude, :latitude)
  end
end