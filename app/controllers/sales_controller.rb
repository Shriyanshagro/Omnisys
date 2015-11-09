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

  def customer
      @customer = Sale.where("user_id = ?" ,  current_user.id).distinct.pluck(:customer)
      render json: @customer
  end

  def item
     @item = Master.distinct.pluck(:item_name )
     render json: @item
  end

  def create
    @sale = Sale.new(sale_params)
    @sale.user_id = current_user.id

    #Now various validations

    #find weather given item and uom matches to master table
    validate = Master.find_by(item_name: @sale.item_name , uom: @sale.unit_of_measure)

    # find the required item in stock
    stock = Stock.find_by(user_id: current_user.id , item_name: @sale.item_name ,
         batch_number: @sale.batch_number )



    respond_to do |format|
     if @sale.quantity<=0
        format.html { redirect_to @sale, notice: 'Given quantity is not acceptable.' }

     elsif !validate.present?
        format.html { redirect_to @sale, notice: 'Give correct Item name and corresponding Unit Of measure.' }

     elsif !stock.present?
        format.html { redirect_to @sale, notice: 'Given Item and corresponding Unit Of Measure is never purchased.' }

      # as specified retailer can sale product even if item's quantity is less than required
 #    elsif stock.quantity < @sale.quantity*$total
  #      format.html { redirect_to @sale, notice: 'Required quantity is not available in stock' }

     else
      # logic to find least count of quantity
      $i=1
      $total=1
      while $i <= validate.level
       factor = Master.find_by(item_name: @sale.item_name , level: $i)
       $total *= factor.units*factor.conversion
       $i += 1
      end
      if @sale.save
        format.html { redirect_to @sale, notice: 'Sale was successfully created.' }
        format.json { render :show, status: :created, location: @sale }

        # method to update stock if any item got saled
          stock.quantity = stock.quantity - @sale.quantity*$total
          stock.save


      else
        format.html { render :new }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
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
    # method to update stock when sale got destroyed.
    stock = Stock.find_by(user_id: current_user.id , item_name: @sale.item_name ,
       batch_number: @sale.batch_number )

    if stock.present?
        stock.quantity = stock.quantity + @sale.quantity
        stock.save

    end

    @sale.destroy
    respond_to do |format|
      format.html { redirect_to sales_url, notice: 'Sale was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def access
          redirect_to controller: 'sales', action: 'index'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_sale
      @sale = Sale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sale_params
      params.require(:sale).permit(:customer, :item_name, :quantity, :unit_of_measure, :batch_number, :expiry_date, :date_of_purchase, :total_price)
    end

end
