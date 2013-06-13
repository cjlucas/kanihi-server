require 'test_helper'

class TracksControllerTest < ActionController::TestCase
  setup do
    @track = tracks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tracks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create track" do
    assert_difference('Track.count') do
      post :create, track: { album_art_id: @track.album_art_id, album_artist: @track.album_artist, album_artist_sort_order: @track.album_artist_sort_order, album_name: @track.album_name, comment: @track.comment, compilation: @track.compilation, composer: @track.composer, date: @track.date, disc_num: @track.disc_num, disc_subtitle: @track.disc_subtitle, disc_total: @track.disc_total, duration: @track.duration, genre: @track.genre, group: @track.group, lyrics: @track.lyrics, mood: @track.mood, mtime: @track.mtime, original_date: @track.original_date, size: @track.size, subtitle: @track.subtitle, track_artist: @track.track_artist, track_artist_sort_order: @track.track_artist_sort_order, track_name: @track.track_name, track_num: @track.track_num, track_total: @track.track_total, uri: @track.uri }
    end

    assert_redirected_to track_path(assigns(:track))
  end

  test "should show track" do
    get :show, id: @track
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @track
    assert_response :success
  end

  test "should update track" do
    put :update, id: @track, track: { album_art_id: @track.album_art_id, album_artist: @track.album_artist, album_artist_sort_order: @track.album_artist_sort_order, album_name: @track.album_name, comment: @track.comment, compilation: @track.compilation, composer: @track.composer, date: @track.date, disc_num: @track.disc_num, disc_subtitle: @track.disc_subtitle, disc_total: @track.disc_total, duration: @track.duration, genre: @track.genre, group: @track.group, lyrics: @track.lyrics, mood: @track.mood, mtime: @track.mtime, original_date: @track.original_date, size: @track.size, subtitle: @track.subtitle, track_artist: @track.track_artist, track_artist_sort_order: @track.track_artist_sort_order, track_name: @track.track_name, track_num: @track.track_num, track_total: @track.track_total, uri: @track.uri }
    assert_redirected_to track_path(assigns(:track))
  end

  test "should destroy track" do
    assert_difference('Track.count', -1) do
      delete :destroy, id: @track
    end

    assert_redirected_to tracks_path
  end
end
