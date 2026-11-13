require "test_helper"

class Admin::CatalogsControllerTest < ActionDispatch::IntegrationTest
  test "should get reload" do
    get admin_catalogs_reload_url
    assert_response :success
  end

  test "should get approvals" do
    get admin_catalogs_approvals_url
    assert_response :success
  end
end
