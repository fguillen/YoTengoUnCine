class Front::DonationsController < Front::FrontController
  skip_before_filter :verify_authenticity_token, :only => [:ipn]

  def create
    donation = Donation.build_by_kind(params[:donation][:kind])
    donation.save!

    url =
      PaypalWrapper.get_authorization_url(
        donation.description,
        donation.amount,
        confirm_front_donation_url(donation),
        cancel_front_donations_url
      )

    redirect_to url
  end

  def confirm
    donation = Donation.find(params[:id])
    donation.set_authorize_params(request.url)
    donation.confirm(ipn_front_donation_url(donation))

    redirect_to front_page_path("home"), :notice => "Donacion aceptada"
  end

  def ipn
    donation = Donation.find(params[:id])
    donation.set_ipn_params(params)
    donation.pay

    render :text => "ok"
  end

  def cancel
    redirect_to front_page_path("cinecitarios"), :alert => "Donacion cancelada"
  end
end
