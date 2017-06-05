require 'test_helper'

class CourierControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courier_index_url
    assert_response :success
  end

end
