class StocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock, only: [ :update,:show]
  # before_action :logged_in_user, only: [:index]

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

  end

  def expiry_date
      @date = Stock.where('item_name = ? and batch_number = ? and user_id = ? ', params[:item] , params[:batch] , current_user.id).pluck(:expiry_date )
      render json: @date

  end

  def batch
     @batch = Stock.where('item_name = ? and user_id  = ?' , params[:name], current_user.id).distinct.pluck(:batch_number )
     render json: @batch
  end

  def item
      @item = Report.where("user_id = ?" , current_user.id).pluck(:item_name )
      render json: @item
  end

  # POST /stocks
  # POST /stocks.json
  def create
    @stock = Stock.new(stock_params)
    @stock.user_id = current_user.id
    @item = Stock.where("user_id = ? and item_name = ?" ,  current_user.id , @stock.item_name )
    @uom = Stock.where("user_id = ? and item_name = ? and unit_of_measure = ?" ,  current_user.id , @stock.item_name , @stock.unit_of_measure)
    @stocks = Stock.where("user_id = ? and item_name = ? and unit_of_measure = ? and batch_number = ? " ,  current_user.id , @stock.item_name , @stock.unit_of_measure , @stock.batch_number)
    time = Time.now.strftime("%Y-%m-%d")
    respond_to do |format|
        if @stock.expiry_date <= Date.parse(time)
            format.html { redirect_to @stock, notice: 'Product is alreday expired, check the  expiry date' }

        elsif @stock.quantity <= 0
            format.html { redirect_to @stock, notice: 'Quantity should be positive' }

        else
            if !@stocks.present?

                 master =  Master.where("item_name = ? and uom = ?" , @stock.item_name , @stock.unit_of_measure)

                #   if item is not in masters then consider it as personal item
                    if master.present?
                        # base is master's row with level = 1 , to get base uom
                        base = Master.where("item_name = ?" , @stock.item_name )
                        base = base.where("level = ? " , "1")
                        uom = base.pluck(:uom)
                        uom = uom[0]
                        mrp = base.pluck(:mrp)
                        mrp = mrp[0]
                        #  onlt if given unit_of_measure is base_uom(level=1)
                        if uom.to_s == @stock.unit_of_measure.to_s
                            price = @stock.quantity*mrp
                            purchase=Purchase.create(user_id: current_user.id , wholesaler: "Stock Correction",item_name: @stock.item_name ,
                            batch_number: @stock.batch_number ,unit_of_measure: uom ,
                            expiry_date: @stock.expiry_date , quantity:@stock.quantity , date_of_purchase: time , total_price:price)

                            # update in report
                            report = Report.find_by(item_name: @stock.item_name , user_id: current_user.id)
                            if report.present?
                              report.value = (price + report.value*report.quantity)/(@stock.quantity + report.quantity)
                              report.quantity = report.quantity + @stock.quantity
                              report.save
                            else
                              report=Report.create(user_id:current_user.id , item_name:@stock.item_name,value:(price/(@stock.quantity)),
                              quantity:@stock.quantity)
                            end

                            if @stock.save
                            format.html { redirect_to @stock, notice: 'New Item has been successfully added.' }
                            format.json { render :show, status: :created, location: @stock }
                            else
                              format.html { render :new }
                              format.json { render json: @stock.errors, status: :unprocessable_entity }
                            end

                        else
                            format.html { redirect_to @stock, notice: 'Item from masters list is only allowed with base unit_of_measure(level=1)' }
                            format.json { render :show, status: :created, location: @stock }
                        end

                    else
                        #  is personal item present in stock
                        if @item.present?
                            # only 1 uom is allowed for personal item
                            if @uom.present?
                                # find average value of product
                                report = Report.find_by(item_name: @stock.item_name , user_id: current_user.id)
                                price = @stock.quantity*report.value

                                purchase=Purchase.create(user_id: current_user.id , wholesaler: "Stock Correction",item_name: @stock.item_name ,
                                batch_number: @stock.batch_number ,unit_of_measure: @stock.unit_of_measure ,
                                expiry_date: @stock.expiry_date , quantity:@stock.quantity , date_of_purchase: time , total_price:price)

                                report.value = (price + report.value*report.quantity)/(@stock.quantity + report.quantity)
                                report.quantity = report.quantity + @stock.quantity
                                report.save

                                if @stock.save
                                format.html { redirect_to @stock, notice: 'New Item has been successfully added.' }
                                format.json { render :show, status: :created, location: @stock }
                                else
                                  format.html { render :new }
                                  format.json { render json: @stock.errors, status: :unprocessable_entity }
                                end

                            else
                                #  as defined Personal item with only one unit_of_measure is allowed
                                format.html { redirect_to @stock, notice: 'Personal item with only one unit_of_measure is allowed' }
                                format.json { render :show, status: :created, location: @stock }
                            end

                        else
                            purchase=Purchase.create(user_id: current_user.id , wholesaler: "Stock Correction",item_name: @stock.item_name ,
                            batch_number: @stock.batch_number ,unit_of_measure: @stock.unit_of_measure ,
                            expiry_date: @stock.expiry_date , quantity:@stock.quantity , date_of_purchase: time , total_price:0)

                            report=Report.create(user_id:current_user.id , item_name:@stock.item_name,value:0,
                            quantity:@stock.quantity)

                            if @stock.save
                            format.html { redirect_to @stock, notice: 'New Item has been successfully added.' }
                            format.json { render :show, status: :created, location: @stock }
                            else
                              format.html { render :new }
                              format.json { render json: @stock.errors, status: :unprocessable_entity }
                            end

                        end
                    end
            else
                format.html { redirect_to @stock, notice: 'Item with corresponding unit_of_measure and batch number already exist.' }
                format.json { render json: @stock.errors, status: :unprocessable_entity }
            end
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

  def correct
      @stocks = Stock.where("user_id = ?" ,  current_user.id).ids
      $count = 0

        for $i in @stocks
          if params[:@stocks][:stock][:"#{$i}"][:item_name].present?
              $time = Time.now
              # find the requires row in Stock db
              data = Stock.find("#{$i}")
              # find the average value of product
              $value = Report.find_by(item_name: data.item_name , user_id: current_user.id)
              $value = $value.value
              # condition to choose weather to make sale or purchase
              if data.quantity > params[:@stocks][:stock][:"#{$i}"][:item_name].to_f
                  # .to_f function changes a string to integer
                  $count+=1
                  stock=Sale.create(customer:"Stock Correction",user_id: current_user.id , item_name: data.item_name ,
                  batch_number: data.batch_number ,unit_of_measure: data.unit_of_measure ,
                  expiry_date: data.expiry_date , quantity:(data.quantity - params[:@stocks][:stock][:"#{$i}"][:item_name].to_f),date_of_purchase:"#{$time}",total_price:$value*(data.quantity - params[:@stocks][:stock][:"#{$i}"][:item_name].to_f))

                  data.quantity= params[:@stocks][:stock][:"#{$i}"][:item_name].to_f
                  data.save

              elsif data.quantity < params[:@stocks][:stock][:"#{$i}"][:item_name].to_f
                  $count+=1
                  stock=Purchase.create(wholesaler:"Stock Correction",user_id: current_user.id , item_name: data.item_name ,
                  batch_number: data.batch_number ,unit_of_measure: data.unit_of_measure ,
                  expiry_date: data.expiry_date , quantity:(params[:@stocks][:stock][:"#{$i}"][:item_name].to_f - data.quantity ),date_of_purchase:"#{$time}" , total_price: $value*(params[:@stocks][:stock][:"#{$i}"][:item_name].to_f - data.quantity))

                  data.quantity= params[:@stocks][:stock][:"#{$i}"][:item_name].to_f
                  data.save

                report = Report.find_by(item_name: data.item_name , user_id: current_user.id)
                report.value = ($value*(params[:@stocks][:stock][:"#{$i}"][:item_name].to_f - data.quantity) + report.value*report.quantity)/((params[:@stocks][:stock][:"#{$i}"][:item_name].to_f - data.quantity ) + report.quantity)
                report.quantity = report.quantity + (params[:@stocks][:stock][:"#{$i}"][:item_name].to_f - data.quantity )
                report.save

              end

          end
       end
        if $count>0
          respond_to do |format|
              format.html { redirect_to stocks_path, notice: "Stock has been updated ." }
          end
        else
            respond_to do |format|
                format.html { redirect_to stocks_path, notice: "No change in stocks ." }
            end
        end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.where("user_id = ?" ,  current_user.id).find(params[:id])
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
