require 'test_helper'

class GpspositionControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get gpsposition_index_url
    assert_response :success
  end

end
