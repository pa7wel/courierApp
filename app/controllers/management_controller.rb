class ManagementController < ApplicationController
  def index
  	@users = User.all;
  end
end
