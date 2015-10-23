require 'test_helper'

class PurchasesControllerTest < ActionController::TestCase
  setup do
    @purchase = purchases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase" do
    assert_difference('Purchase.count') do
      post :create, purchase: { batch_number: @purchase.batch_number, date_of_purchase: @purchase.date_of_purchase, expiry_date: @purchase.expiry_date, item_name: @purchase.item_name, quantity: @purchase.quantity, total_price: @purchase.total_price, unit_of_measure: @purchase.unit_of_measure, wholesaler: @purchase.wholesaler }
    end

    assert_redirected_to purchase_path(assigns(:purchase))
  end

  test "should show purchase" do
    get :show, id: @purchase
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase
    assert_response :success
  end

  test "should update purchase" do
    patch :update, id: @purchase, purchase: { batch_number: @purchase.batch_number, date_of_purchase: @purchase.date_of_purchase, expiry_date: @purchase.expiry_date, item_name: @purchase.item_name, quantity: @purchase.quantity, total_price: @purchase.total_price, unit_of_measure: @purchase.unit_of_measure, wholesaler: @purchase.wholesaler }
    assert_redirected_to purchase_path(assigns(:purchase))
  end

  test "should destroy purchase" do
    assert_difference('Purchase.count', -1) do
      delete :destroy, id: @purchase
    end

    assert_redirected_to purchases_path
  end
end
