module Api
  class BreedDetectionController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def detect
      breed = params[:breed]
      data = BreedDetector.detect_from_breed(breed)
      
      render json: data
    end
  end
end
