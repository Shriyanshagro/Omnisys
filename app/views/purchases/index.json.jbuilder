json.array!(@purchases) do |purchase|
  json.extract! purchase, :id, :wholesaler, :item_name, :quantity, :unit_of_measure, :batch_number, :expiry_date, :date_of_purchase, :total_price
  json.url purchase_url(purchase, format: :json)
end
