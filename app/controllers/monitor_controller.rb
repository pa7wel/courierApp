class MonitorController < ApplicationController
  def index
  	@users = User.all;
  end
end
