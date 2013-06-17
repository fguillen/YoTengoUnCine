require "test_helper"

class Admin::DonationsControllerTest < ActionController::TestCase
  def setup
    setup_admin_user
  end

  def test_index
    donation_1 = FactoryGirl.create(:donation)
    donation_2 = FactoryGirl.create(:donation)

    get :index

    assert_template "admin/donations/index"
    assert_equal([donation_2, donation_1].ids, assigns(:donations).ids)
  end

  def test_show
    donation = FactoryGirl.create(:donation)

    get :show, :id => donation

    assert_template "admin/donations/show"
    assert_equal(donation, assigns(:donation))
  end

  def test_edit
    donation = FactoryGirl.create(:donation)

    get :edit, :id => donation

    assert_template "edit"
    assert_equal(donation, assigns(:donation))
  end

  def test_update_invalid
    donation = FactoryGirl.create(:donation)
    Donation.any_instance.stubs(:valid?).returns(false)

    put :update, :id => donation

    assert_template "edit"
    assert_not_nil(flash[:alert])
  end

  def test_update_valid
    donation = FactoryGirl.create(:donation)

    put(
      :update,
      :id => donation,
      :donation => {
        :amount => "101"
      }
    )

    donation.reload

    assert_redirected_to [:admin, donation]
    assert_not_nil(flash[:notice])

    assert_equal(101, donation.amount)
  end

  def test_destroy
    donation = FactoryGirl.create(:donation)

    delete :destroy, :id => donation

    assert_redirected_to :admin_donations
    assert_not_nil(flash[:notice])

    assert !Donation.exists?(donation.id)
  end

end
