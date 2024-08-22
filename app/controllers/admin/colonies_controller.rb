class Admin::ColoniesController < Admin::BaseController
    
    def index
        @colonies = Colonium.where(is_active: true).order(sector: :asc, junta_nom: :asc)
    end

    def new
        @colony = Colonium.new
    end

    def create

        @colony = Colonium.find_by(junta_nom: params[:junta_nom])

        unless @colony.nil?
            @colony.errors.add(:junta_nom, "Ya existe una colonia con este nombre")
            render :new, status: :unprocessable_entity
            return
        end

        @colony = Colonium.new(junta_nom: params[:junta_nom], sector: params[:sector], is_active: true)
        
        if @colony.save
            redirect_to admin_colonies_path, notice: 'Se agregó la colonia con éxito.'
        end
    end

    def edit
        @colony = Colonium.find_by(id: params[:id])
    end

    def update

        @colony = Colonium.find_by(id: params[:id])

        if @colony.update(junta_nom: params[:junta_nom], sector: params[:sector])
            redirect_to admin_colonies_path, notice: 'Se editó la colonia con éxito.'
        else
            render :edit
        end
    end

    def destroy
        # Revisar si la colonia pertenece a un usuario
        exists = User.joins(:colonium).where(colonia: { id: params[:id] }).exists?

        if exists
            redirect_to admin_colonies_path, alert: 'No se puede eliminar esta colonia. Al menos un usuario pertenece a ella.'
        else
            @colony = Colonium.find_by(id: params[:id])
            
            if @colony.destroy
                redirect_to admin_colonies_path, notice: 'Se eliminó la colonia con éxito.'
            else
                redirect_to admin_colonies_path, notice: 'Ocurrió un error al intentar eliminar esta colonia.'
            end

        end
    end
end