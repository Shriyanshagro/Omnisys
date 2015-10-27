json.array!(@stocks) do |stock|
  json.extract! stock, :id, :item_name, :unit_of_measure, :batch_number, :quantity, :expiry_date
  json.url stock_url(stock, format: :json)
end
