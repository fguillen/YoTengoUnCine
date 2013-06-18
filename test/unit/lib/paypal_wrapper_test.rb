require "test_helper"

class PaypalWrapperTest < ActiveSupport::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def test_get_authorization_url
    response_mock = mock(:success? => true, :Token => "TOKEN")
    client_mock = mock

    PaypalWrapper.stubs(:client).returns(client_mock)

    client_mock.expects(:build_set_express_checkout).with(
      :SetExpressCheckoutRequestDetails => {
        :ReturnURL => "RETURN-URL",
        :CancelURL => "CANCEL-URL",
        :PaymentDetails => [{
          :OrderTotal => {
            :currencyID => "EUR",
            :value => 101.11
          },
          :PaymentDetailsItem => [{
            :Name => "DESCRIPTION",
            :Amount => {
              :currencyID => "EUR",
              :value => 101.11
            },
            :ItemCategory => "Physical"
          }],
          :PaymentAction => "Sale"
        }]
      }
    ).returns("OPTS")

    client_mock.expects(:set_express_checkout).with("OPTS").returns(response_mock)

    url = PaypalWrapper.get_authorization_url("DESCRIPTION", 101.11, "RETURN-URL", "CANCEL-URL")

    assert_equal("https://www.paypal.com/webscr?cmd=_express-checkout&token=TOKEN", url)
  end

  def test_pay
    response_mock = mock(:success? => true)
    client_mock = mock

    PaypalWrapper.stubs(:client).returns(client_mock)

    client_mock.expects(:build_do_express_checkout_payment).with(
      :DoExpressCheckoutPaymentRequestDetails => {
        :PaymentAction => "Sale",
        :Token => "TOKEN",
        :PayerID => "PAYER-ID",
        :PaymentDetails => [{
          :OrderTotal => {
            :currencyID => "EUR",
            :value => 101.11
          },
          :NotifyURL => "IPN_URL"
        }]
      }
    ).returns("OPTS")

    client_mock.expects(:do_express_checkout_payment).with("OPTS").returns(response_mock)

    PaypalWrapper.pay("PAYER-ID", "TOKEN", 101.11, "IPN_URL")
  end

  def test_parse_authorize_response
    authorize_response = "https://url.com?token=THE-TOKEN&PayerID=THE-PAYER-ID"
    authorize_response_parsed = PaypalWrapper.parse_authorize_response(authorize_response)

    assert_equal("THE-TOKEN", authorize_response_parsed.token)
    assert_equal("THE-PAYER-ID", authorize_response_parsed.payer_id)
  end
end
