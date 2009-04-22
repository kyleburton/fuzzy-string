require 'test_helper'

class AtestsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:atests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create atest" do
    assert_difference('Atest.count') do
      post :create, :atest => { }
    end

    assert_redirected_to atest_path(assigns(:atest))
  end

  test "should show atest" do
    get :show, :id => atests(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => atests(:one).to_param
    assert_response :success
  end

  test "should update atest" do
    put :update, :id => atests(:one).to_param, :atest => { }
    assert_redirected_to atest_path(assigns(:atest))
  end

  test "should destroy atest" do
    assert_difference('Atest.count', -1) do
      delete :destroy, :id => atests(:one).to_param
    end

    assert_redirected_to atests_path
  end
end
