 class HomeController < ApplicationController
  
 	def index
  		
  	
	end

	def test
  		some_parameter = params[:some_parameter]
 		 # do something with some_parameter and return the results
 

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end

  	end



	

end