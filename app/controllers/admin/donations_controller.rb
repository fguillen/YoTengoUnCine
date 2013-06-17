class Admin::DonationsController < Admin::AdminController
  before_filter :require_admin_user

  def index
    @donations = Donation.paginate(:page => params[:page], :per_page => 40).order("id desc")
  end

  def show
    @donation = Donation.find(params[:id])
  end

  def edit
    @donation = Donation.find(params[:id])
  end

  def update
    @donation = Donation.find(params[:id])
    @donation.log_book_historian = current_admin_user
    if @donation.update_attributes(params[:donation], :as => :admin)
      redirect_to [:admin, @donation], :notice  => "Successfully updated Donation."
    else
      flash.now[:alert] = "Some error trying to update Donation."
      render :action => 'edit'
    end
  end

  def destroy
    @donation = Donation.find(params[:id])
    @donation.log_book_historian = current_admin_user
    @donation.destroy
    redirect_to :admin_donations, :notice => "Successfully destroyed Donation."
  end
end
