class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :origin_zip
      t.string :destination_zip
      t.float :driving_distance
      t.float :driving_time

      t.timestamps
    end
  end
end
