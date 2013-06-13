require 'test_helper'

class AlbumArtsControllerTest < ActionController::TestCase
  setup do
    @album_art = album_arts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:album_arts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create album_art" do
    assert_difference('AlbumArt.count') do
      post :create, album_art: { checksum: @album_art.checksum, data: @album_art.data, size: @album_art.size }
    end

    assert_redirected_to album_art_path(assigns(:album_art))
  end

  test "should show album_art" do
    get :show, id: @album_art
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @album_art
    assert_response :success
  end

  test "should update album_art" do
    put :update, id: @album_art, album_art: { checksum: @album_art.checksum, data: @album_art.data, size: @album_art.size }
    assert_redirected_to album_art_path(assigns(:album_art))
  end

  test "should destroy album_art" do
    assert_difference('AlbumArt.count', -1) do
      delete :destroy, id: @album_art
    end

    assert_redirected_to album_arts_path
  end
end
