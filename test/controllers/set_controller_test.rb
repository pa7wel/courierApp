require 'test_helper'

class SetControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get set_index_url
    assert_response :success
  end

end
