class PetsController < ApplicationController
  before_action :set_pet, only: [:show, :edit, :update, :destroy]

  def index
    @pets = Current.user.pets.alphabetically
  end

  def show
    @pet = Current.user.pets.find(params[:id])
  end

  def new
    @pet = Current.user.pets.build
  end

  def create
    @pet = Current.user.pets.build(pet_params)

    if @pet.save
      redirect_to dashboard_path, notice: "#{@pet.name} has been added!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @pet.update(pet_params)
      redirect_to dashboard_path, notice: "#{@pet.name} has been updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pet.destroy
    redirect_to dashboard_path, notice: "Pet removed."
  end

  private

  def set_pet
    @pet = Current.user.pets.find(params[:id])
  end

  def pet_params
    params.require(:pet).permit(:name, :species, :breed, :age, :notes)
  end
end
