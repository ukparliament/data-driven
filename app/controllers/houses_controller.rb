class HousesController < ApplicationController
	def index 
		data = House.all
		@houses = data[:hierarchy]
		
		format(data)
	end

	def show
		house_uri = resource_uri(params[:id])
		data = House.find(house_uri)
		@house = data[:hierarchy]
		
		format(data)
	end
end
