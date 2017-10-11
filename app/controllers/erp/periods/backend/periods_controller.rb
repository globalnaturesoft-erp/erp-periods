module Erp
  module Periods
    module Backend
      class PeriodsController < Erp::Backend::BackendController
        before_action :set_period, only: [:edit, :update, :set_active, :set_deleted]
        before_action :set_periods, only: [:set_active_all, :set_deleted_all]
        
        # GET /periods
        def index
        end

        # POST /periods/list
        def list
          @periods = Period.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end
    
        # GET /periods/new
        def new
          @period = Period.new
          
          if request.xhr?
            render '_form', layout: nil, locals: {period: @period}
          end
        end
    
        # GET /periods/1/edit
        def edit
        end
    
        # POST /periods
        def create
          @period = Period.new(period_params)
          @period.creator = current_user
          
          if @period.save
            @period.set_active
            if request.xhr?
              render json: {
                status: 'success',
                text: @period.name,
                value: @period.id
              }
            else
              redirect_to erp_periods.edit_backend_period_path(@period), notice: t('.success')
            end
          else
            if request.xhr?
              render '_form', layout: nil, locals: {period: @period}
            else
              render :new
            end
          end
        end
    
        # PATCH/PUT /periods/1
        def update
          if @period.update(period_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @period.name,
                value: @period.id
              }
            else
              redirect_to erp_periods.edit_backend_period_path(@period), notice: t('.success')
            end
          else
            render :edit
          end
        end
        
        # dataselect /periods
        def dataselect
          respond_to do |format|
            format.json {
              render json: Period.dataselect(params[:keyword], params)
            }
          end
        end
    
        # Active /periods/status?id=1
        def set_active
          @period.set_active

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end
    
        # Delete /periods/status?id=1
        def set_deleted
          @period.set_deleted

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end
    
        # Active all /periods/status?ids=1,2..
        def set_active_all
          @periods.set_active_all

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end
    
        # Deleted all /periods/status?ids=1,2..
        def set_deleted_all
          @periods.set_deleted_all

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_period
            @period = Period.find(params[:id])
          end
          
          def set_periods
            @periods = Period.where(id: params[:ids])
          end
    
          # Only allow a trusted parameter "white list" through.
          def period_params
            params.fetch(:period, {}).permit(:name, :from_date, :to_date, :status)
          end
      end
    end
  end
end
