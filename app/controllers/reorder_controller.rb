class ReorderController < ApplicationController
  def index
      @report = Report.where('user_id = ?', current_user.id).all
      @name = []
      purchase = []
      stock = []
      sold = []
      first = []
      last = []
      time = []
      reorder_point = []
      @reorder_quantity = []
      @flag = []
      @len = @report.length - 1
      for i in 0..@len
          @name[i] = @report[i].item_name
          purchase[i] = @report[i].quantity
          stock[i] = Stock.where("user_id = ? and item_name = ?" , current_user.id , @report[i].item_name).sum(:quantity)
          sold[i] = purchase[i] - stock[i]
          first[i] = Sale.where("user_id = ? and item_name = ?" , current_user.id , @report[i].item_name).first
          if first[i].present?
              first[i] = first[i].date_of_purchase
              last[i] = Sale.where("user_id = ? and item_name = ?" , current_user.id , @report[i].item_name).last
              last[i] = last[i].date_of_purchase
              time [i] = (last[i] - first[i]).to_i
              if time[i] != 0
                  reorder_point[i] = (sold[i]*3)/time[i]
                  @reorder_quantity[i] = reorder_point[i] * 10
                  if reorder_point[i] >= stock[i]
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
