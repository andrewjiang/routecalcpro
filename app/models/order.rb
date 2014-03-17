class Order < ActiveRecord::Base

	validates :email, presence: true
	validates :routes, presence: true
	validates :book, presence: true

	has_attached_file :book


end
