json.array!(@routes) do |route|
  json.extract! route, :id, :origin, :destination, :driving_distance, :driving_time
  json.url route_url(route, format: :json)
end
