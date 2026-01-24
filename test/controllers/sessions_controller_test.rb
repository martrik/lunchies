require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "callback without Google flash redirects to new with alert" do
    get session_callback_path
    assert_redirected_to new_session_path

    follow_redirect!
    assert_match /failed|try again/i, flash[:alert].to_s
  end

  test "destroy" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_nil cookies["session_id"]
  end
end
