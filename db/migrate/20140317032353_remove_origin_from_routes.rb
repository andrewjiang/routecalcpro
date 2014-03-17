class RemoveOriginFromRoutes < ActiveRecord::Migration
  def change
    remove_column :routes, :origin_zip, :string
    remove_column :routes, :destination_zip, :string
  end
end
