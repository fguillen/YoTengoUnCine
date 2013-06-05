class Donation < ActiveRecord::Base
  attr_protected :nil

  validates :amount, :presence => true
  validates :description, :presence => true

  def pay
    raise Exception, "OnlinePurchase [#{id}] already paid" if paid?

    PaypalWrapper.pay(payer_id, token, amount)
    update_attribute(:paid_at, Time.now)
  end

  def set_authorize_params(authorize_response)
    paypal_params = PaypalWrapper.parse_authorize_response(authorize_response)

    update_attributes!(
      :token => paypal_params.token,
      :payer_id => paypal_params.payer_id
    )
  end

  def paid?
    !paid_at.nil?
  end
end
