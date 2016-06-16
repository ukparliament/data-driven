class HousesController < ApplicationController
	def index 
		data = House.all
		@houses = data[:hierarchy]
		format(data)
	end

	def show
		house_uri = resource_uri(params[:id])
		@house = House.find(house_uri)
		
		format(@house)
	end
end
