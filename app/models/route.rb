class Route < ActiveRecord::Base

		def self.to_csv(options = {})
			CSV.generate(options) do |csv|
				csv << column_names
				all.each do |route|
					csv << route.attributes.values_at(*column_names)
				end
			end
		end 

		def self.import(file)
		  CSV.foreach(file.file_path, headers: true) do |row|
		  	Route.create! row.to_hash
		  end
		end
end
