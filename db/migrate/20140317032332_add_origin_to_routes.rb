class AddOriginToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :origin, :string
    add_column :routes, :destination, :string
  end
end
