class Verification::ResidenceController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_verified!
  before_action :verify_lock, only: [:new, :create]
  before_action :is_valid_image, only: [:create]
  skip_authorization_check

  RESIDENCE_PARAMS = [
    :document_number,
    :document_type,
    # :phone_number,
    # :postal_code,
    :terms_of_service,
    :ife
    # :birth_certificate
    # :born_names,
    # :paternal_last_name,
    # :maternal_last_name,
    # :date_of_birth,
    # :birthplace,
    # :gender
  ].freeze

  def new
    @residence = Verification::Residence.new
  end

  # def create

  #   new_user_data = residence_params.merge(user: current_user) { |key, oldval, newval| newval == nil ? oldval : newval}

  #   @residence = Verification::Residence.new(new_user_data)

  #   if @residence.save
  #     redirect_to new_address_user_path, notice: t('verification.residence.create.flash.success')
  #   else
  #     render :new
  #   end
  # end

  def create

    new_user_data = residence_params.merge(user: current_user) { |key, oldval, newval| newval == nil ? oldval : newval}

    @residence = Verification::Residence.new(new_user_data)

    if current_user.is_minor?
      image = Image.new(imageable_id: current_user.id, imageable_type: "User", title: "tutor_birth_certificate", user_id: current_user.id)
      image.attachment = params[:residence][:birth_certificate]

      if @residence.save && image.save
        redirect_to account_path, notice: t('verification.residence.create.flash.success')
      else
        redirect_to account_path, alert: "Error al intentar registrar tu identificación"
      end
    else
      if @residence.save
        redirect_to account_path, notice: t('verification.residence.create.flash.success')
      else
        redirect_to account_path, alert: "Error al intentar registrar tu identificación"
      end
    end
  end

  def is_valid_image
    if residence_params[:ife]&.headers&.include?(".jfif")
      redirect_to new_residence_path, flash: { error: "Formato de imagen no válido. Intenta con otra." }
    end
  end

  private

    def residence_params
      params.require(:residence).permit(RESIDENCE_PARAMS)
    end
end
