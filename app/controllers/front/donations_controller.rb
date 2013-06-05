class Front::DonationsController < Front::FrontController
  def create
    donation = Donation.create!(params[:donation])

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
    donation.pay

    redirect_to front_page_path("home"), :notice => "Donacion aceptada"
  end

  def cancel
    redirect_to front_page_path("cinecitarios"), :alert => "Donacion cancelada"
  end
end
