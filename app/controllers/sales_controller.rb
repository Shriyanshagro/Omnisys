class SalesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sale, only: [:show, :edit, :update, :destroy]

  # GET /sales
  # GET /sales.json
  def index
    @sales = Sale.where("user_id = ?" ,  current_user.id)
    
  end

  # GET /sales/1
  # GET /sales/1.json
  def show
  end

  # GET /sales/new
  def new
    @sale = Sale.new
  end

  # GET /sales/1/edit
  def edit
  end

  # POST /sales
  # POST /sales.json
   def item_update(@sale)
        @item_list= Item.where("user_id = ? and item_name = ?" ,  current_user.id , @sale.item_name )
        if @item_list.nil?
          Item.create(:item_name => @sale.item_name , :quantity => @sale.quantity , :user_id => current_user.id)
        else
          @item_list.quantity = @item_list.quantity - @sale.quantity
          Item.update_columns(:quantity => @item_list.quantity).where("user_id = ? and item_name = ?" ,  current_user.id , @sale.item_name)

        end    
        
   end

  def create
    @sale = Sale.new(sale_params)
    @sale.user_id = current_user.id
    respond_to do |format|
      if @sale.save
        format.html { redirect_to @sale, notice: 'Sale was successfully created.' }
        format.json { render :show, status: :created, location: @sale }
        
        item_update(@sale)
        
      else
        format.html { render :new }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    
    
    end
      
  end

  # PATCH/PUT /sales/1
  # PATCH/PUT /sales/1.json
  def update
    respond_to do |format|
      if @sale.update(sale_params)
        format.html { redirect_to @sale, notice: 'Sale was successfully updated.' }
        format.json { render :show, status: :ok, location: @sale }
      else
        format.html { render :edit }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales/1
  # DELETE /sales/1.json
  def destroy
    @sale.destroy
    respond_to do |format|
      format.html { redirect_to sales_url, notice: 'Sale was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sale
      @sale = Sale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sale_params
      params.require(:sale).permit(:customer, :item_name, :quantity, :unit_of_measure, :batch_number, :expiry_date, :date_of_purchase, :total_price)
    end
end
