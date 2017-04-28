class PlacesController < ApplicationController
  #before_action :set_place, only: [:show, :edit, :update, :destroy]

  # GET /places
  # GET /places.json
  def index
    @places = Place.all
  end

  # GET /places/1
  # GET /places/1.json
  def show
  end

  # GET /places/new
  def new
    @place = Place.new
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places
  # POST /places.json
  def create
    #place_params[:data].each do |data| 
     # @place = Place.new(data)
   # end
   
   @job_id = HardWorker.perform_async(place_params)

   # @place = Place.new(place_params)

   # respond_to do |format|
    #  if @place.save
    #    format.html { redirect_to @place, notice: 'Place was successfully created.' }
    #    format.json { render :show, status: :created, location: @place }
    #  else
    #    format.html { render :new }
     #   format.json { render json: @place.errors, status: :unprocessable_entity }
     # end
    #end
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

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to @place, notice: 'Place was successfully updated.' }
        format.json { render :show, status: :ok, location: @place }
      else
        format.html { render :edit }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place.destroy
    respond_to do |format|
      format.html { redirect_to places_url, notice: 'Place was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_place
      @place = Place.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def place_params
      params.permit(:dataJSON)
    end
end
