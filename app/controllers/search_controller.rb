class SearchController < ApplicationController
  allow_unauthenticated_access

  def index
    @pros = ProProfile.setup_complete.includes(:user, :reviews, :services)

    # Location filter
    if params[:location].present?
      @pros = @pros.by_location(params[:location])
    end

    # Service type filter
    if params[:service_type].present?
      @pros = @pros.joins(:services).where("services.name ILIKE ?", "%#{params[:service_type]}%").distinct
    end

    # Pet-based filtering: if a pet is selected, use its tags
    if params[:pet_id].present? && authenticated?
      pet = Current.user.pets.find_by(id: params[:pet_id])
      if pet
        # Filter by pet's characteristics
        apply_pet_filters(pet)
      end
    else
      # Manual filters
      apply_manual_filters
    end

    # Minimum rating filter
    if params[:min_rating].present?
      min = params[:min_rating].to_i
      @pros = @pros.select { |p| p.average_rating >= min }
    end

    # Has availability this week
    if params[:available_this_week] == "1"
      @pros = @pros.select(&:has_availability?)
    end

    # Sort
    case params[:sort]
    when "rating"
      @pros = @pros.sort_by { |p| -p.average_rating }
    when "reviews"
      @pros = @pros.sort_by { |p| -p.total_reviews }
    when "newest"
      @pros = @pros.sort_by { |p| -p.created_at.to_i }
    else
      # Default: verified first, then by rating
      @pros = @pros.sort_by { |p| [p.is_verified ? 0 : 1, -p.average_rating] }
    end

    # Ensure it's an array for views
    @pros = @pros.to_a
  end

  private

  def apply_pet_filters(pet)
    # Filter by dog size
    if pet.size.present?
      @pros = @pros.where("dog_sizes ILIKE ?", "%#{pet.size}%")
    end

    # Filter by temperament
    if pet.temperament.present?
      @pros = @pros.where("temperaments ILIKE ?", "%#{pet.temperament}%")
    end

    # Filter by puppy
    if pet.is_puppy?
      @pros = @pros.where(accepts_puppies: true)
    end

    # Filter by senior
    if pet.is_senior?
      @pros = @pros.where(accepts_senior_dogs: true)
    end

    # Filter by special needs
    if pet.has_special_needs?
      @pros = @pros.where(accepts_special_needs: true)
    end

    # Filter by breed experience
    if pet.breed.present?
      @pros = @pros.where("breed_specialties ILIKE ?", "%#{pet.breed}%").or(
        @pros.where(breed_specialties: [nil, ""])
      )
    end
  end

  def apply_manual_filters
    # Dog size filter
    if params[:dog_size].present?
      @pros = @pros.where("dog_sizes ILIKE ?", "%#{params[:dog_size]}%")
    end

    # Temperament filter
    if params[:temperament].present?
      @pros = @pros.where("temperaments ILIKE ?", "%#{params[:temperament]}%")
    end

    # Accepts puppies
    if params[:accepts_puppies] == "1"
      @pros = @pros.where(accepts_puppies: true)
    end

    # Accepts seniors
    if params[:accepts_seniors] == "1"
      @pros = @pros.where(accepts_senior_dogs: true)
    end

    # Accepts special needs
    if params[:accepts_special_needs] == "1"
      @pros = @pros.where(accepts_special_needs: true)
    end

    # Breed specialty
    if params[:breed_specialty].present?
      @pros = @pros.where("breed_specialties ILIKE ?", "%#{params[:breed_specialty]}%")
    end
  end
end
