# frozen_string_literal: true

module Pros
  class ServicesController < ApplicationController
    before_action :require_pro_profile
    before_action :set_service, only: %i[edit update destroy]

    def index
      @services = current_pro_profile.services.order(:created_at)
      
      if params[:inline]
        render partial: "pros/services/inline", layout: false
      end
    end

    def new
      @service = current_pro_profile.services.build
    end

    def create
      @service = current_pro_profile.services.build(service_params)

      if @service.save
        redirect_to pros_services_path(inline: params[:inline]), notice: "Service added!"
      else
        if params[:inline]
          @services = current_pro_profile.services.order(:created_at)
          render partial: "pros/services/inline", layout: false, status: :unprocessable_entity
        else
          render :new, status: :unprocessable_entity
        end
      end
    end

    def edit
      if params[:inline]
        render partial: "pros/services/edit_inline", layout: false
      end
    end

    def update
      if @service.update(service_params)
        redirect_to pros_services_path(inline: params[:inline]), notice: "Service updated!"
      else
        if params[:inline]
          render partial: "pros/services/edit_inline", layout: false, status: :unprocessable_entity
        else
          render :edit, status: :unprocessable_entity
        end
      end
    end

    def destroy
      @service.destroy
      redirect_to pros_services_path(inline: params[:inline]), notice: "Service removed."
    end

    private

    def set_service
      @service = current_pro_profile.services.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :description, :price, :currency, :duration, :payment_type, :photo, :photo_url)
    end

    def current_pro_profile
      @current_pro_profile ||= Current.user.pro_profile
    end

    def require_pro_profile
      redirect_to root_path, alert: "You need a pro profile." unless current_pro_profile
    end
  end
end
