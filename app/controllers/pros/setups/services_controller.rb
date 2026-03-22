class Pros::Setups::ServicesController < ApplicationController
  before_action :set_pro_profile
  before_action :set_service, only: %i[ destroy ]

  def create
    @service = @pro_profile.services.build(service_params)

    if @service.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to pros_setup_path }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @service.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to pros_setup_path }
    end
  end

  private

    def set_pro_profile
      @pro_profile = Current.user.pro_profile
    end

    def set_service
      @service = @pro_profile.services.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :description, :price, :currency, :duration, :payment_type)
    end
end
