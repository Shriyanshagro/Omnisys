class PurchasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_purchase, only: [:show, :edit, :update, :destroy]

  # GET /purchases
  # GET /purchases.json
  def index
    @purchases = Purchase.where("user_id = ?" ,  current_user.id)
  end

  # GET /purchases/1
  # GET /purchases/1.json
  def show
  end

  # GET /purchases/new
  def new
    @purchase = Purchase.new
  end

  # GET /purchases/1/edit
  def edit
  end

  # POST /purchases
  # POST /purchases.json
  def create
    @purchase = Purchase.new(purchase_params)
    @purchase.user_id = current_user.id
    respond_to do |format|
      if @purchase.save
        format.html { redirect_to @purchase, notice: 'Purchase was successfully created.' }
        format.json { render :show, status: :created, location: @purchase }

        @stock_list= Stock.where("user_id = ? and item_name = ? and batch_no = ? and  unit_of_measure = ?" ,
          current_user.id , @purchase.item_name ,@purchase.batch_number ,@purchase.unit_of_measure)
        
        if @stock_list.nil?  # ==false
          Stock.update_columns(:quantity => @newstock_list.quantity).where("user_id = ? and item_name = ? and
            batch_number = ? and  unit_of_measure = ?" ,current_user.id , @purchase.item_name ,@purchase.batch_number,
            @purchase.unit_of_measure)
        
        else
          Stock.create(:item_name => @purchase.item_name , :quantity => @purchase.quantity ,
           :user_id => current_user.id, :batch_number => @purchase.batch_number , 
           :expiry_date => @purchase.expiry_date , :unit_of_measure => @purchase.unit_of_measure
            )

        end  

      else
        format.html { render :new }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
 
    end
  end

  # PATCH/PUT /purchases/1
  # PATCH/PUT /purchases/1.json
  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to @purchase, notice: 'Purchase was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase }
      else
        format.html { render :edit }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchases/1
  # DELETE /purchases/1.json
  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to purchases_url, notice: 'Purchase was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase
      @purchase = Purchase.find(params[:id])

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_params
      params.require(:purchase).permit(:wholesaler, :item_name, :quantity, :unit_of_measure, :batch_number, :expiry_date, :date_of_purchase, :total_price)
    end
end
