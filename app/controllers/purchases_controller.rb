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
    #find weather given item and uom matches to master table
    validate = Master.find_by(item_name: @purchase.item_name , uom: @purchase.unit_of_measure)


    # to find the unit_of_measure of least level
    factor = Master.find_by(item_name: @purchase.item_name , level: 1)

    respond_to do |format|
     if @purchase.quantity<=0
        format.html { redirect_to @purchase, notice: 'Given quantity is not acceptable.' }

     elsif !validate.present?
        format.html { redirect_to @purchase, notice: 'Give correct Item name and corresponding Unit Of measure.' }

     else
       # logic to find least count of quantity
       $i=1
       $total=1
       while $i <= validate.level
       factor = Master.find_by(item_name: @purchase.item_name , level: $i)
       $total *= factor.units*factor.conversion
       $i += 1
       end
       if @purchase.save
        format.html { redirect_to @purchase, notice: 'Purchase was successfully created.' }
        format.json { render :show, status: :created, location: @purchase }

        # method to update stock if any item got purchased
        stock = Stock.find_by(user_id: current_user.id , item_name: @purchase.item_name ,
         batch_number: @purchase.batch_number )

        if stock.present?

          stock.quantity = stock.quantity + @purchase.quantity*$total
          stock.save

        else
          stock=Stock.create(user_id: current_user.id , item_name: @purchase.item_name ,
         batch_number: @purchase.batch_number ,unit_of_measure: factor.uom ,
         expiry_date: @purchase.expiry_date , quantity:@purchase.quantity*$total)

        end

        report = Report.find_by(item_name: @purchase.item_name , user_id: current_user.id)
        if report.present?
          report.value = (@purchase.total_price + report.value*report.quantity)/(@purchase.quantity*$total + report.quantity)
          report.quantity = report.quantity + @purchase.quantity*$total
          report.save
        else
          report=Report.create(user_id:current_user.id , item_name:@purchase.item_name,value:(@purchase.total_price/(@purchase.quantity*$total)),
          quantity:@purchase.quantity*$total)
        end

      else
        format.html { render :new }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
     end
    end
  end

  def wholesaler
      @wholesaler = Purchase.where("user_id = ?" ,  current_user.id).distinct.pluck(:wholesaler)
      render json: @wholesaler
  end

  def item
     @item = Master.distinct.pluck(:item_name )
     render json: @item
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
    # method to update stock when purchase got destroyed.
    stock = Stock.find_by(user_id: current_user.id , item_name: @purchase.item_name ,
       batch_number: @purchase.batch_number )

    if stock.present?
        stock.quantity = stock.quantity - @purchase.quantity
        stock.save

    end
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

