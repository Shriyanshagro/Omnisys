json.array!(@masters) do |master|
  json.extract! master, :id, :item_name, :uom, :units, :level, :conversion, :mrp
  json.url master_url(master, format: :json)
end
