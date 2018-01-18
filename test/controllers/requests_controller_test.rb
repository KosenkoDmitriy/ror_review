require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get request_review" do
    get requests_request_review_url
    assert_response :success
  end

  test "should get google_review" do
    get requests_google_review_url
    assert_response :success
  end

  test "should get local_review" do
    get requests_local_review_url
    assert_response :success
  end

  test "should get review_feedback" do
    get requests_review_feedback_url
    assert_response :success
  end

end
