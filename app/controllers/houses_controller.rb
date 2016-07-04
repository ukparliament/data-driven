class HousesController < ApplicationController
	def index 
		data = House.all
		@houses = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def show
		house_uri = resource_uri(params[:id])
		data = House.find(house_uri)
		@house = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end
end