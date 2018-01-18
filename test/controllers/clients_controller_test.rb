require 'test_helper'

class ClientsControllerTest < ActionDispatch::IntegrationTest
  test "should get send_request_by_email" do
    get clients_send_request_by_email_url
    assert_response :success
  end

  test "should get send_request_by_sms" do
    get clients_send_request_by_sms_url
    assert_response :success
  end

  test "should get create_notification" do
    get clients_create_notification_url
    assert_response :success
  end

  test "should get edit_notification" do
    get clients_edit_notification_url
    assert_response :success
  end

  test "should get update_notification" do
    get clients_update_notification_url
    assert_response :success
  end

end
