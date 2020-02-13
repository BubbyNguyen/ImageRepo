require 'test_helper'

class PhotoControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get photo_index_url
    assert_response :success
  end

  test "should get upload" do
    get photo_upload_url
    assert_response :success
  end

  test "should get view" do
    get photo_view_url
    assert_response :success
  end

end
