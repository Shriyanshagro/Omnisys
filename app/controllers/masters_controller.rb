class MastersController < ApplicationController
  before_action :authenticate_user!
  before_action :check
  before_action :set_master, only: [:show, :edit, :update]

  # GET /masters
  # GET /masters.json
  def index
    @masters = Master.all
  end

  # GET /masters/1
  # GET /masters/1.json
  def show
  end

  # GET /masters/new
  def new
    @master = Master.new
  end

  # GET /masters/1/edit
  def edit
  end

  # POST /masters
  # POST /masters.json
  def create
    @master = Master.new(master_params)

    respond_to do |format|
      if @master.save
        format.html { redirect_to @master, notice: 'Master was successfully created.' }
        format.json { render :show, status: :created, location: @master }
      else
        format.html { render :new }
        format.json { render json: @master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /masters/1
  # PATCH/PUT /masters/1.json
  def update
    respond_to do |format|
      if @master.update(master_params)
        format.html { redirect_to @master, notice: 'Master was successfully updated.' }
        format.json { render :show, status: :ok, location: @master }
      else
        format.html { render :edit }
        format.json { render json: @master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /masters/1
  # DELETE /masters/1.json
  def destroy
    @master.destroy
    respond_to do |format|
      format.html { redirect_to masters_url, notice: 'Master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # /masters/1/delete
  def delete
    id = params[:id]
    Master.find(id).destroy
    respond_to do |format|
      format.html { redirect_to masters_url, notice: 'Master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_master
      @master = Master.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def master_params
      params.require(:master).permit(:item_name, :uom, :units, :level, :conversion, :mrp)
    end

    # global method for authentication
    def check
        if current_user.id!=1
          respond_to do |format|
          format.html { redirect_to stocks_path, notice: "Sorry you don't have access for this page ." }
          end
        end
    end

end
