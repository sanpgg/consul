class Users::PasswordsController < Devise::PasswordsController
    def new
      super
    end
  
    def create

        self.resource = resource_class.send_reset_password_instructions(resource_params)
      
        if successfully_sent?(resource)
            session[:user_email] = resource.email
            redirect_to sent_recovery_mail_path, notice: ''
        else
            respond_with(resource)
        end
      end      
  
    def edit
      super
    end
  
    def update
      super
    end
  
    def destroy
      super
    end
  end