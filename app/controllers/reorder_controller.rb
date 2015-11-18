class ReorderController < ApplicationController
  def index
      @report = Report.where('user_id = ?', current_user.id).all
      @name = []
      purchase = []
      @risk_stock = []
      @safe_stock = []
      sold = []
    #   stores first date of sold
      first = []
      #   stores last date of sold
      last = []
      #   stores time difference of sold
      time = []
      reorder_point = []
      @reorder_quantity = []
    #   if flag = 2 item needs to reorder
      @flag = []
      @len = @report.length - 1
      timer = Time.now.strftime("%Y-%m-%d")
      for i in 0..@len
          @name[i] = @report[i].item_name
          purchase[i] = @report[i].quantity
        #   expiry_date > current date
          @safe_stock[i] = Stock.where("user_id = ? and item_name = ? and expiry_date > ?" , current_user.id , @report[i].item_name, timer).sum(:quantity)
          #   expiry_date <= current date
          @risk_stock[i] = Stock.where("user_id = ? and item_name = ? and expiry_date <= ?" , current_user.id , @report[i].item_name, timer).sum(:quantity)
          # total sale
          sold[i] = purchase[i] - @safe_stock[i] - @risk_stock[i]
        #   first sale
          first[i] = Sale.where("user_id = ? and item_name = ?" , current_user.id , @report[i].item_name).first
          if first[i].present?
              first[i] = first[i].date_of_purchase
              # last sale
              last[i] = Sale.where("user_id = ? and item_name = ?" , current_user.id , @report[i].item_name).last
              last[i] = last[i].date_of_purchase
          # time between first and last sale
              time[i] = (last[i] - first[i]).to_i
              if time[i] != 0
                  reorder_point[i] = (sold[i]*3)/time[i]
                  @reorder_quantity[i] = reorder_point[i] * 10
                  if reorder_point[i] >= @safe_stock[i]
                      @flag[i] = 2
                  else
                      @flag[i] = 1
                  end
              else
                  @flag[i] = 1
              end
          else
              @flag[i] = 1
          end

      end
  end
end
