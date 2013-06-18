require "test_helper"

class Front::PagesControllerTest < ActionController::TestCase
  def test_home
    get :show, :id => "home"

    assert :success
    assert_template "front/pages/home"
  end

  def test_chair_support
    get :show, :id => "chair_support"

    assert :success
    assert_template "front/pages/chair_support"
  end

  def test_cinecitarios
    get :show, :id => "cinecitarios"

    assert :success
    assert_template "front/pages/cinecitarios"
  end
end
