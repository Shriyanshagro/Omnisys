require 'test_helper'

class SalesControllerTest < ActionController::TestCase
  setup do
    @sale = sales(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sales)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sale" do
    assert_difference('Sale.count') do
      post :create, sale: { batch_number: @sale.batch_number, customer: @sale.customer, date_of_purchase: @sale.date_of_purchase, expiry_date: @sale.expiry_date, item_name: @sale.item_name, quantity: @sale.quantity, total_price: @sale.total_price, unit_of_measure: @sale.unit_of_measure }
    end

    assert_redirected_to sale_path(assigns(:sale))
  end

  test "should show sale" do
    get :show, id: @sale
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sale
    assert_response :success
  end

  test "should update sale" do
    patch :update, id: @sale, sale: { batch_number: @sale.batch_number, customer: @sale.customer, date_of_purchase: @sale.date_of_purchase, expiry_date: @sale.expiry_date, item_name: @sale.item_name, quantity: @sale.quantity, total_price: @sale.total_price, unit_of_measure: @sale.unit_of_measure }
    assert_redirected_to sale_path(assigns(:sale))
  end

  test "should destroy sale" do
    assert_difference('Sale.count', -1) do
      delete :destroy, id: @sale
    end

    assert_redirected_to sales_path
  end
end