class Donation < ActiveRecord::Base

  KINDS = {
    :donation_5 => "donation_5",
    :donation_15 => "donation_15",
    :donation_30 => "donation_30",
    :donation_50 => "donation_50",
    :chair_support => "chair_support",
  }

  attr_accessible :kind

  validates :amount, :presence => true
  validates :kind, :presence => true, :inclusion => { :in => KINDS.values }
  validates :description, :presence => true

  def confirm(ipn_url)
    raise Exception, "Donation [#{id}] already confirmed" if confirmed?

    PaypalWrapper.pay(payer_id, token, amount, ipn_url)
    update_attribute(:confirmed_at, Time.now)
  end

  def pay
    raise Exception, "Donation [#{id}] already paid" if paid?

    update_attribute(:paid_at, Time.now)
  end

  def set_ipn_params(params)
    self.payer_email = params[:payer_email]
    self.payer_address_street = params[:address_street]
    self.payer_address_zip = params[:address_zip]
    self.payer_name = "#{params[:first_name]} #{params[:last_name]}"
    self.payer_address_country_code = params[:address_country_code]
    self.payer_address_name = params[:address_name]
    self.payer_address_country = params[:address_country]
    self.payer_address_city = params[:address_city]
    self.payer_address_state = params[:address_state]
    self.transaction_id = params[:txn_id]

    self.save!
  end

  def set_authorize_params(authorize_response)
    paypal_params = PaypalWrapper.parse_authorize_response(authorize_response)

    self.token = paypal_params.token
    self.payer_id = paypal_params.payer_id

    self.save!
  end

  def paid?
    !paid_at.nil?
  end

  def confirmed?
    !confirmed_at.nil?
  end

  def self.build_by_kind(kind)
    donation = Donation.new
    donation.kind = kind

    case kind
    when Donation::KINDS[:donation_5]
      donation.amount = 5
      donation.description = I18n.t("donations.donation_15.description")

    when Donation::KINDS[:donation_15]
      donation.amount = 5
      donation.description = I18n.t("donations.donation_15.description")

    when Donation::KINDS[:donation_30]
      donation.amount = 30
      donation.description = I18n.t("donations.donation_30.description")

    when Donation::KINDS[:donation_50]
      donation.amount = 50
      donation.description = I18n.t("donations.donation_50.description")

    else
      raise Exception, "Donation kind not supported [#{kind}]"
    end

    donation
  end
end
