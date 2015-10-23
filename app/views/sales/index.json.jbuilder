json.array!(@sales) do |sale|
  json.extract! sale, :id, :customer, :item_name, :quantity, :unit_of_measure, :batch_number, :expiry_date, :date_of_purchase, :total_price
  json.url sale_url(sale, format: :json)
end
