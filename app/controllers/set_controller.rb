class SetController < ApplicationController
  before_action :authenticate_user!
  def index
  	@users = User.all;
  end

  def new

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
      $array_cities = ActiveSupport::JSON.decode(@solution_array)
    elsif Sidekiq::Status::failed? job_id
      render :plain => 'Failed', :status => 500
    else
      render :plain => '', :status => 202
    end
  end
  
  def createTour

	id = params[:id]
    $array_cities.each do |i|
        Route.create(city: i, user_id: id)
    end
    flash[:notice] = "Route was saved successfully!!!"
    redirect_to(:controller => 'home', :action => 'index')
    #render :plain => 'Saved', :status => 200
  end

   protected
    def my_params
      params.permit(:cities => [], :distances => [:origin, :destination, :distance])
    end

    def my_params_job
      params.permit(:id)
    end

    def params_user_id
      params.permit(:id)
    end

end
