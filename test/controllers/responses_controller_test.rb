require 'test_helper'

class ResponsesControllerTest < ActionDispatch::IntegrationTest
  test "should get user_response" do
    get responses_user_response_url
    assert_response :success
  end

end
