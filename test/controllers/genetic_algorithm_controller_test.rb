require 'test_helper'

class GeneticAlgorithmControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get genetic_algorithm_index_url
    assert_response :success
  end

end
