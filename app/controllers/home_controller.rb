 class HomeController < ApplicationController
  #before_action :set_place, only: [:show, :edit, :update, :destroy]

 	def index
  		
	end

  def create
    dane = my_params
    @job_id = HardWorker.perform_async(my_params.to_json)

    render :status => :accepted, :json => { jobId: @job_id }
  end
  
  def fetch
    job_id = params[:job_id]
    if Sidekiq::Status::complete? job_id
      render :status => 200, :text => Sidekiq::Status::get(job_id, :output)
    elsif Sidekiq::Status::failed? job_id
      render :status => 500, :text => 'Failed'
    else
      render :status => 202, :text => ''
    end
  end
  
  protected
    def my_params
      params.permit(:cities => [], :distances => [:origin, :destination, :distance])
    end


end