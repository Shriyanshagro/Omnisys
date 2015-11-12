class PurchasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_purchase, only: [:show, :edit, :update, :destroy]
  before_action :check
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

    # stores current date only not
    time = Time.now.strftime("%Y-%m-%d")
    respond_to do |format|
     if @purchase.quantity<=0
        format.html { redirect_to @purchase, notice: 'Given quantity is not acceptable.' }

    elsif @purchase.expiry_date < Date.parse(time)
        format.html { redirect_to @purchase, notice: 'Product is alreday expired, check the  expiry date' }

     else
        #find weather given item and uom matches to master table
    validate = Master.find_by(item_name: @purchase.item_name , uom: @purchase.unit_of_measure)

     if validate.present?
        # to find the unit_of_measure of least level
        factor = Master.find_by(item_name: @purchase.item_name , level: 1)
       # logic to find least count of quantity
        $i=1
        $total=1
        while $i <= validate.level
            factor = Master.find_by(item_name: @purchase.item_name , level: $i)
            $total *= factor.units*factor.conversion
            $i += 1
        end
        factor = Master.find_by(item_name: @purchase.item_name , level: 1)

       if @purchase.save

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

            format.html { redirect_to @purchase, notice: 'Purchase was successfully created.' }
            format.json { render :show, status: :created, location: @purchase }

        else
            format.html { render :new }
            format.json { render json: @purchase.errors, status: :unprocessable_entity }

        end

        # if item is not from masters list but personal
     else
         if @purchase.save

             stock_item = Stock.find_by(user_id: current_user.id , item_name: @purchase.item_name )
             stock_uom = Stock.find_by(user_id: current_user.id , item_name: @purchase.item_name ,
                   unit_of_measure:@purchase.unit_of_measure)

                   #Only one uom is allowed for personal items.
             if stock_item.present? and !stock_uom.present?
                  format.html { redirect_to @purchase, notice: 'Only one uom is allowed for personal items.' }

                  # create a new item in personal list
             elsif !stock_item.present? and !stock_uom.present?
                 stock=Stock.create(user_id: current_user.id , item_name: @purchase.item_name ,
                batch_number: @purchase.batch_number ,unit_of_measure: @purchase.unit_of_measure ,
                expiry_date: @purchase.expiry_date , quantity: @purchase.quantity)

                report=Report.create(user_id:current_user.id , item_name:@purchase.item_name,value:(@purchase.total_price/(@purchase.quantity)),
                quantity:@purchase.quantity)

                 # update the  stock level
             elsif  stock_item.present? and stock_uom.present?

                         stock = Stock.find_by(user_id: current_user.id , item_name: @purchase.item_name ,
                          batch_number: @purchase.batch_number )

                         if stock.present?

                           stock.quantity = stock.quantity + @purchase.quantity
                           stock.save

                         else
                           stock=Stock.create(user_id: current_user.id , item_name: @purchase.item_name ,
                          batch_number: @purchase.batch_number ,unit_of_measure: @purchase.unit_of_measure ,
                          expiry_date: @purchase.expiry_date , quantity: @purchase.quantity)

                         end
                       report = Report.find_by(item_name: @purchase.item_name , user_id: current_user.id)
                       report.value = (@purchase.total_price + report.value*report.quantity)/(@purchase.quantity + report.quantity)
                       report.quantity = report.quantity + @purchase.quantity
                       report.save

             end

             format.html { redirect_to @purchase, notice: 'Purchase was successfully created.' }
             format.json { render :show, status: :created, location: @purchase }

         else
             format.html { render :new }
             format.json { render json: @purchase.errors, status: :unprocessable_entity }

         end


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
     @item += Stock.where("user_id = ?" , current_user.id).distinct.pluck(:item_name )
    #  now to get distinct items from master and personal list
     @item = @item.uniq
     render json: @item
  end

  def uom
      if params[:name].present?
            @uom = Master.where("item_name = ?" , params[:name]).distinct.pluck(:uom)
            if @uom.present?
                render json: @uom
            else
                    @uom = Stock.where("item_name = ? and user_id = ?" , params[:name], current_user.id).distinct.pluck(:unit_of_measure)
                    render json: @uom
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

    def check
        if params[:action] == "edit"
            respond_to do |format|
              format.html { redirect_to purchases_url, notice: 'No access.' }
              format.json { head :no_content }
          end
      end
  end


end
