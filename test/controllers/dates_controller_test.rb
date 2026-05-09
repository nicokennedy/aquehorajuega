require "test_helper"

class DatesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dates_show_url
    assert_response :success
  end
end
