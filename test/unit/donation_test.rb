# encoding: utf-8

require "test_helper"

class DonationTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert FactoryGirl.create(:donation).valid?
  end

  def test_scope_paid
    donation_1 = FactoryGirl.create(:donation, :paid_at => Time.now)
    donation_2 = FactoryGirl.create(:donation, :paid_at => nil)

    assert_equal([donation_1].ids, Donation.paid.ids)
  end

  def test_confirm
    donation = FactoryGirl.create(:donation, :payer_id => "PAYER_ID", :token => "TOKEN", :amount => 100)
    PaypalWrapper.expects(:pay).with("PAYER_ID", "TOKEN", 100, "IPN_URL")

    donation.confirm("IPN_URL")

    donation.reload
    assert_not_nil(donation.confirmed_at)
  end

  def test_pay
    donation = FactoryGirl.create(:donation)

    donation.pay

    donation.reload
    assert_not_nil(donation.paid_at)
  end

  def test_set_ipn_params
    params = {
      :payer_email => "PAYER_EMAIL",
      :address_street => "ADDRESS_STREET",
      :address_zip => "ADDRESS_ZIP",
      :first_name => "FIRST_NAME",
      :last_name => "LAST_NAME",
      :address_country_code => "ADDRESS_COUNTRY_CODE",
      :address_name => "ADDRESS_NAME",
      :address_country => "ADDRESS_COUNTRY",
      :address_city => "ADDRESS_CITY",
      :address_state => "ADDRESS_STATE",
      :txn_id => "TXN_ID"
    }

    donation = FactoryGirl.create(:donation)
    donation.set_ipn_params(params)
    donation.reload

    assert_equal("PAYER_EMAIL", donation.payer_email)
    assert_equal("ADDRESS_STREET", donation.payer_address_street)
    assert_equal("ADDRESS_ZIP", donation.payer_address_zip)
    assert_equal("ADDRESS_STREET", donation.payer_address_street)
    assert_equal("FIRST_NAME LAST_NAME", donation.payer_name)
    assert_equal("ADDRESS_COUNTRY_CODE", donation.payer_address_country_code)
    assert_equal("ADDRESS_NAME", donation.payer_address_name)
    assert_equal("ADDRESS_COUNTRY", donation.payer_address_country)
    assert_equal("ADDRESS_CITY", donation.payer_address_city)
    assert_equal("ADDRESS_STATE", donation.payer_address_state)
    assert_equal("TXN_ID", donation.transaction_id)
  end

  def test_set_authorize_params
    donation = FactoryGirl.create(:donation)
    donation.set_authorize_params("https://url.com?token=THE-TOKEN&PayerID=THE-PAYER-ID")

    donation.reload
    assert_equal("THE-TOKEN", donation.token)
    assert_equal("THE-PAYER-ID", donation.payer_id)
  end

  def test_paid_question_mark
    donation_1 = FactoryGirl.create(:donation, :paid_at => Time.now)
    donation_2 = FactoryGirl.create(:donation, :paid_at => nil)

    assert_equal(true, donation_1.paid?)
    assert_equal(false, donation_2.paid?)
  end

  def test_confirmed_question_mark
    donation_1 = FactoryGirl.create(:donation, :confirmed_at => Time.now)
    donation_2 = FactoryGirl.create(:donation, :confirmed_at => nil)

    assert_equal(true, donation_1.confirmed?)
    assert_equal(false, donation_2.confirmed?)
  end

  def test_build_by_kind
    donation = Donation.build_by_kind(Donation::KINDS[:donation_5])
    assert_equal(Donation::KINDS[:donation_5], donation.kind)
    assert_equal(5, donation.amount)
    assert_equal(I18n.t("donations.donation_5.description"), donation.description)

    donation = Donation.build_by_kind(Donation::KINDS[:donation_15])
    assert_equal(Donation::KINDS[:donation_15], donation.kind)
    assert_equal(15, donation.amount)
    assert_equal(I18n.t("donations.donation_15.description"), donation.description)

    donation = Donation.build_by_kind(Donation::KINDS[:donation_30])
    assert_equal(Donation::KINDS[:donation_30], donation.kind)
    assert_equal(30, donation.amount)
    assert_equal(I18n.t("donations.donation_30.description"), donation.description)

    donation = Donation.build_by_kind(Donation::KINDS[:donation_50])
    assert_equal(Donation::KINDS[:donation_50], donation.kind)
    assert_equal(50, donation.amount)
    assert_equal(I18n.t("donations.donation_50.description"), donation.description)

    donation = Donation.build_by_kind(Donation::KINDS[:chair_support])
    assert_equal(Donation::KINDS[:chair_support], donation.kind)
    assert_equal(180, donation.amount)
    assert_equal(I18n.t("donations.chair_support.description"), donation.description)
  end

  def test_set_ipn_params_invalid_byte_sequence_error
    params={
      "mc_gross" => "5.00",
      "protection_eligibility" => "Eligible",
      "address_status" => "unconfirmed",
      "payer_id" => "NN2THN5NFSXPQ",
      "tax" => "0.00",
      "address_street" => "c./ XXX n\xBA 2, XXX",
      "payment_date" => "02:53:50 Jun 07, 2013 PDT",
      "payment_status" => "Completed",
      "charset" => "windows-1252",
      "address_zip" => "07011",
      "first_name" => "Fco. XXXX",
      "mc_fee" => "0.52",
      "address_country_code" => "ES",
      "address_name" => "Fco. XXXX Pach\xF3n Paz",
      "notify_version" => "3.7",
      "custom" => "",
      "payer_status" => "verified",
      "address_country" => "Spain",
      "address_city" => "Palma de Mallorca",
      "quantity" => "1",
      "verify_sign" => "XXX-HDRwJ0.ML.g",
      "payer_email" => "xxx@gmail.com",
      "txn_id" => "7VU770913E683421X",
      "payment_type" => "instant",
      "last_name" => "Pach\xF3n Paz",
      "address_state" => "Islas Baleares",
      "receiver_email" => "xxx@cineciutat.org",
      "payment_fee" => "",
      "receiver_id" => "DEQLBWYB9QDBS",
      "txn_type" => "express_checkout",
      "item_name" => "",
      "mc_currency" => "EUR",
      "item_number" => "",
      "residence_country" => "ES",
      "handling_amount" => "0.00",
      "transaction_subject" => "",
      "payment_gross" => "",
      "shipping" => "0.00",
      "ipn_track_id" => "978c66d7d13f5",
      "id" => "6"
    }.symbolize_keys

    donation = FactoryGirl.create(:donation)
    donation.set_ipn_params(params)

    donation.reload
    assert_equal("c./ XXX n\xBA 2, XXX", donation.payer_address_street)
    assert_equal("Fco. XXXX Pach\xF3n Paz", donation.payer_address_name)
    assert_equal("Fco. XXXX Pach\xF3n Paz", donation.payer_name)
  end
end
