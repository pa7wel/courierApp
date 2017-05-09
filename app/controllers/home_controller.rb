 class HomeController < ApplicationController

 	def index
  		
	end

  def create
    @job_id = HardWorker.perform_async(my_params.to_json)
    render :status => :accepted, :json => { jobId: @job_id }

  end
  
  def fetch
    job_id = my_params_job['id']

    if Sidekiq::Status::complete? job_id
      render :plain => Sidekiq::Status::get(job_id, :solution), :status => 200
      @solution_array = Sidekiq::Status::get(job_id, :solution_array)
      @array_cities = ActiveSupport::JSON.decode(@solution_array)
      @array_cities.each do |i|
        Route.create(city: i)
      end

    elsif Sidekiq::Status::failed? job_id
      render :plain => 'Failed', :status => 500
    else
      render :plain => '', :status => 202
    end
  end

  def createTour(dane)
    pry.binding
    @dane = Sidekiq::Status::get(@job_id, :solution_array)
    @array_cities = ActiveSupport::JSON.decode(@dane)
    @array_cities.each do |i|
      @zapisz = Route.new(place_params)
      @zapisz.save
    end

  end
  
  protected
    def my_params
      params.permit(:cities => [], :distances => [:origin, :destination, :distance])
    end

    def my_params_job
      params.permit(:id)
    end

    def place_params
      params.permit(:city)
    end
end