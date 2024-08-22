class AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  load_and_authorize_resource class: "User"

  def update_profile
    @user = current_user

    if @user.colonium_ids.blank? && user_params[:colonium_ids].blank?
      @user.errors.add(:colonium_ids, "Debes seleccionar tu colonia")
      return render :profile
    end

    if @user.update(user_params)
      redirect_to account_path, notice: 'Tu perfil ha sido actualizado correctamente.'
    else
      render :profile
    end
  end

  def profile
  end

  def show
  end

  def update
    if @account.update(account_params)
      redirect_to account_path, notice: t("flash.actions.save_changes.notice")
    else
      @account.errors.messages.delete(:organization)
      render :show
    end
  end

  def complete_profile
    @residence = Verification::Residence.new
    # puts current_user.images.first().attachment.url.inspect
  end

  private

    def set_account
      @account = current_user
    end

    def account_params
      attributes = if @account.organization?
                     [:phone_number, :email_on_comment, :email_on_comment_reply, :newsletter,
                      organization_attributes: [:name, :responsible_name]]
                   else
                     [:username, :public_activity, :public_interests, :email_on_comment,
                      :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter,
                      :official_position_badge, :recommended_debates, :recommended_proposals]
                   end
      params.require(:account).permit(*attributes)
    end

    def user_params
      params.require(:user).permit(:born_names, :paternal_last_name, :maternal_last_name, :gender, :birthplace, :date_of_birth,
        :phone_number, :colonium_ids, :tutor, :email_on_comment, :email_on_comment_reply, :email_on_direct_message, :email_digest,
        :newsletter, :official_position_badge, :recommended_debates, :recommended_proposals)
    end

end
