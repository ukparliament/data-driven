class HousesController < ApplicationController
	def index 
		@houses = House.all

		format(@houses)
	end

	def show
		house_uri = resource_uri(params[:id])
		@house = House.show(house_uri)
		
		format(@house)
	end
end
