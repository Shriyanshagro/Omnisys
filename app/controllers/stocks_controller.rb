class StocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock, only: [:show, :edit, :update, :destroy]

  # GET /stocks
  # GET /stocks.json
  def index
    @stocks = Stock.where("user_id = ?" ,  current_user.id)
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
    @stock = Stock.new

  end  
  # GET /stocks/1/edit
  def edit
    check
  end

  # POST /stocks
  # POST /stocks.json
  def create
    @stock = Stock.new(purchase_params)
    @stock.user_id = current_user.id
    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: 'Purchase was successfully created.' }
        format.json { render :show, status: :created, location: @stock }

      else
        format.html { render :new }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
 
    end
  end
 
  # PATCH/PUT /stocks/1
  # PATCH/PUT /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: 'Stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1
  # DELETE /stocks/1.json
  def destroy
    @stock.destroy
    respond_to do |format|
      format.html { redirect_to stocks_url, notice: 'Stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def report

    if params[:q].present?
      @stocks = Stock.where("user_id = ?" ,  current_user.id)
      @stocks = @stocks.where("item_name = ?" ,params[:q]).all
      if @stocks.present?
        @average = Report.where("user_id = ?" ,  current_user.id)
        @average = @average.where("item_name = ?" , params[:q])
      else
        respond_to do |format|
          format.html { redirect_to report_stocks_path, notice: "Sorry given item doesn't exist ." }
        end
      end
    end  
  end
    
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_params
      params.require(:stock).permit(:item_name, :unit_of_measure, :batch_number, :quantity, :expiry_date)
    end

    def check
      respond_to do |format|
          format.html { redirect_to stocks_path, notice: "Sorry you don't have access for this page ." }
    end
  end      
end
