class Users::SessionsController < Devise::SessionsController

  def session_problem
  end

  def sent_recovery_mail
  end

  def create
    self.resource = warden.authenticate(scope: resource_name, recall: "#{controller_path}#new")
  
    if resource && resource.valid_password?(params[:user][:password])
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      redirect_to new_user_session_path(:email => params[:user][:login]), alert: "Correo electrónico o contraseña incorrecta"
    end
  end

  def check_email

    exists = User.exists?(email: params[:email])

    if exists
      redirect_to new_user_session_path(:email => params[:email])
    else
      redirect_to new_user_registration_path, alert: "¡El correo #{params[:email]} no existe, regístrate!"
    end

  end

  private

    def after_sign_in_path_for(resource)
      if !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        if current_user.level_two_and_three_verified?
          budgets_path
        else
          account_path
        end
      end
    end

    def after_sign_out_path_for(resource)
      root_path
    end

    def verifying_via_email?
      return false if resource.blank?
      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end
end
