require "test_helper"

class ProProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pro_profiles_index_url
    assert_response :success
  end

  test "should get show" do
    get pro_profiles_show_url
    assert_response :success
  end

  test "should get new" do
    get pro_profiles_new_url
    assert_response :success
  end

  test "should get create" do
    get pro_profiles_create_url
    assert_response :success
  end

  test "should get edit" do
    get pro_profiles_edit_url
    assert_response :success
  end

  test "should get update" do
    get pro_profiles_update_url
    assert_response :success
  end
end
