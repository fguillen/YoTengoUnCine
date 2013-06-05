puts "XXX: PaypalWrapper"

require "uri"
require "cgi"

class PaypalWrapper
  def self.get_authorization_url(description, amount, return_url, cancel_url)
    opts =
      client.build_set_express_checkout(
        :SetExpressCheckoutRequestDetails => {
          :ReturnURL => return_url,
          :CancelURL => cancel_url,
          :PaymentDetails => [{
            :OrderTotal => {
              :currencyID => "EUR",
              :value => amount
            },
            :PaymentDetailsItem => [{
              :Name => description,
              :Amount => {
                :currencyID => "EUR",
                :value => amount
              },
              :ItemCategory => "Physical"
            }],
            :PaymentAction => "Sale"
          }]
        }
      )

    set_express_checkout_response = client.set_express_checkout(opts)

    if set_express_checkout_response.success?
      base_host = APP_CONFIG[:paypal]["mode"] == "sandbox" ? "www.sandbox.paypal.com" : "www.paypal.com"
      "https://#{base_host}/webscr?cmd=_express-checkout&token=#{set_express_checkout_response.Token}"
    else
      raise Exception, set_express_checkout_response.Errors
    end
  end

  def self.pay(payer_id, token, amount, ipn_url)
    opts =
      client.build_do_express_checkout_payment(
        :DoExpressCheckoutPaymentRequestDetails => {
          :PaymentAction => "Sale",
          :Token => token,
          :PayerID => payer_id,
          :PaymentDetails => [{
            :OrderTotal => {
              :currencyID => "EUR",
              :value => amount
            },
            :NotifyURL => ipn_url
          }]
        }
      )

    do_express_checkout_payment_response = client.do_express_checkout_payment(opts)

    puts "XXX: do_express_checkout_payment_response: #{do_express_checkout_payment_response.inspect}"

    puts "XXX 1: #{do_express_checkout_payment_response.DoExpressCheckoutPaymentResponseDetails.inspect}"
    puts "XXX 2: #{do_express_checkout_payment_response.FMFDetails.inspect}"


    raise Exception, "ERROR in payment: #{do_express_checkout_payment_response.Errors}" if !do_express_checkout_payment_response.success?
  end

  def self.parse_authorize_response(authorize_response)
    params = CGI.parse(URI.parse(authorize_response).query)

    OpenStruct.new(
      :token => params["token"].first,
      :payer_id => params["PayerID"].first
    )
  end

  def self.client
    return @client if @client

    PayPal::SDK.configure(APP_CONFIG[:paypal])

    @client = PayPal::SDK::Merchant.new
    @client
  end
end