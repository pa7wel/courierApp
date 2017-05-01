 class HomeController < ApplicationController

 	def index
  		
	end

  def create
    @job_id = HardWorker.perform_async(my_params.to_json)
    render :status => :accepted, :json => { jobId: @job_id }
   
    if Sidekiq::Status::complete? @job_id
      @data = Sidekiq::Status::get_all @job_id
      puts @data
    end
  end
  
  def fetch
    job_id = my_params_job['id']

    if Sidekiq::Status::complete? job_id
      render :plain => Sidekiq::Status::get(job_id, :solution), :status => 200
    elsif Sidekiq::Status::failed? job_id
      render :plain => 'Failed', :status => 500
    else
      render :plain => '', :status => 202
    end
  end
  
  protected
    def my_params
      params.permit(:cities => [], :distances => [:origin, :destination, :distance])
    end

    def my_params_job
      params.permit(:id)
    end
end