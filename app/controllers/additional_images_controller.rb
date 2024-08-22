class AdditionalImagesController < ApplicationController
  skip_authorization_check only: :destroy

  def destroy
    @additional_image = AdditionalImage.find_by(id: params[:id])

    unless @additional_image.nil?
      @additional_image.destroy
    else
      @additional_image = Image.find_by(id: params[:id])

      @additional_image.destroy unless @additional_image.nil?
    end

    respond_to do |format|
      format.html do
        if request.referer.ends_with?('/edit')
          redirect_to request.referer
          # Utiliza el archivo destroy.js.erb cuando se llama desde la vista de Cocoon
        else
          # Utiliza la respuesta JSON cuando se llama desde otras partes de la aplicación
          render json: {}, status: 200
        end
      end
      format.js do
        if request.referer.ends_with?('/edit')
          redirect_to request.referer
          # Utiliza el archivo destroy.js.erb cuando se llama desde la vista de Cocoon
        else
          # Utiliza la respuesta JSON cuando se llama desde otras partes de la aplicación
          render json: {}, status: 200
        end
      end
    end
  end
end
