# frozen_string_literal: true

module Api
  class ValidationsController < ApplicationController
    allow_unauthenticated_access
    skip_before_action :verify_authenticity_token
    
    def check_email
      email = params[:email].to_s.downcase.strip
      available = email.present? && !User.exists?(email_address: email)
      
      render json: { available: available }
    end
  end
end
