class SalesController < ApplicationController
  before_action :authenticate_user!
  # authenticated to use only show method , i.e it can;t be updated , edit or  destroy
  before_action :set_sale, only: [:show]

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

  #   to send expiry date of particualar item_name ,associated to a specific batch_number and user_id ,in form of json
      #   conditions => in Url item,batch should be available
      #  Url generated from Js script function => getexpiry_date() of _form.html.erb file under Views of different controllers
      #   send date in form of json

#   to send customer names' associated to a specific user_id ,in form of json
  def customer
      @customer = Sale.where("user_id = ?" ,  current_user.id).distinct.pluck(:customer)
  #   send date in form of json
      render json: @customer
  end

  def create
    @sale = Sale.new(sale_params)
    @sale.user_id = current_user.id

    #Now various validations
    respond_to do |format|
     if @sale.quantity<=0
        format.html { redirect_to @sale, notice: 'Given quantity is not acceptable.' }

      # as specified retailer can sale product even if item's quantity is less than required
 #    elsif stock.quantity < @sale.quantity*$total
  #      format.html { redirect_to @sale, notice: 'Required quantity is not available in stock' }

     elsif @sale.total_price<=0
      format.html { redirect_to @sale, notice: 'Total price less than zero is not exceptable.' }

     else
        #find weather given item and uom matches to master table
        validate = Master.find_by(item_name: @sale.item_name , uom: @sale.unit_of_measure)

            #  if item is in masters list
        if validate.present?
            # find the required item in stock
            stock = Stock.find_by(user_id: current_user.id , item_name: @sale.item_name ,
                 batch_number: @sale.batch_number )

                #   no sale if item is not in stocks "list"
         if !stock.present?
             format.html { redirect_to @sale, notice: 'Item is not in stocks' }

         else
              # logic to find least count of quantity
             $i=1
             $total=1
             while $i <= validate.level
              factor = Master.find_by(item_name: @sale.item_name , level: $i)
              $total *= factor.units*factor.conversion
              $i += 1
             end
             mrp = validate.mrp * @sale.quantity

            #  sale cannot be greater than MRP
             if @sale.total_price > mrp
                 format.html { redirect_to @sale , notice: 'Total price cannot be greater than maximium selling price.' }

             elsif @sale.save
               # method to update stock if any item got saled
                 stock.quantity = stock.quantity - @sale.quantity*$total
                 stock.save

                 #   handling total sold in Order table
                 order = Order.find_by(item_name: @sale.item_name , user_id: current_user.id)

                 if order.present?
                     order.sold = order.sold + (@sale.quantity*$total )
                     if order.last < @sale.date_of_purchase
                     order.last = @sale.date_of_purchase
                     end
                     if order.first > @sale.date_of_purchase
                         order.first = @sale.date_of_purchase
                     end
                     order.save
                 else
                     order = Order.create(user_id:current_user.id , item_name:@sale.item_name,
                     sold:@sale.quantity*$total,first:@sale.date_of_purchase,last:@sale.date_of_purchase)
                 end

                 #   in case when there is some conflicts between stock correction and manual feeding
                 order = Order.find_by(item_name: @sale.item_name , user_id: current_user.id)
                 if order.present? and order.last < order.first
                     temp= order.last
                     order.last = order.first
                     order.first = temp
                     order.save
                 end
               format.html { redirect_to @sale , notice: 'Sale was successfully created.' }
               format.json { render :show, status: :created, location: @sale }

             else
               format.json { render json: @sale.errors, status: :unprocessable_entity }
             end
         end

        else
            stock_item = Stock.find_by(user_id: current_user.id , item_name: @sale.item_name )
            stock_uom = Stock.find_by(user_id: current_user.id , item_name: @sale.item_name ,
                  unit_of_measure:@sale.unit_of_measure)

                #   all possible cases when item saled is from personal list
            if !stock_item.present?
                format.html { redirect_to @sale, notice: 'Item is not in stocks list' }

            elsif stock_item.present? and !stock_uom.present?
                 format.html { redirect_to @sale, notice: 'Only one uom is allowed for personal items.' }

            else
                stock = Stock.find_by(user_id: current_user.id , item_name: @sale.item_name ,
                 batch_number: @sale.batch_number ,unit_of_measure:@sale.unit_of_measure)

              if @sale.save
                # method to update stock if any item got saled
                  stock.quantity = stock.quantity - @sale.quantity
                  stock.save

                  #   handling total sold in Order table
                  order = Order.find_by(item_name: @sale.item_name , user_id: current_user.id)

                  if order.present?
                      order.sold = order.sold + (@sale.quantity )
                      if order.last < @sale.date_of_purchase
                      order.last = @sale.date_of_purchase
                      end
                      if order.first > @sale.date_of_purchase
                          order.first = @sale.date_of_purchase
                      end
                      order.save
                  else
                      order = Order.create(user_id:current_user.id , item_name:@sale.item_name,
                      sold:@sale.quantity,first:@sale.date_of_purchase,last:@sale.date_of_purchase)
                  end

                  #   in case when there is some conflicts between stock correction and manual feeding
                  order = Order.find_by(item_name: @sale.item_name , user_id: current_user.id)
                  if order.present? and order.last < order.first
                      temp= order.last
                      order.last = order.first
                      order.first = temp
                      order.save
                  end

                    format.html { redirect_to @sale , notice: 'Sale was successfully created.' }
                    format.json { render :show, status: :created, location: @sale }

              else
                format.json { render json: @sale.errors, status: :unprocessable_entity }
              end
            end
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
    @sale.destroy
    respond_to do |format|
      format.html { redirect_to sales_url, notice: 'Sale was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_sale
      @sale = Sale.where("user_id = ?" ,  current_user.id).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sale_params
      params.require(:sale).permit(:customer, :item_name, :quantity, :unit_of_measure, :batch_number, :expiry_date, :date_of_purchase, :total_price)
    end


end
