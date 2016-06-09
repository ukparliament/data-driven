class HousesController < ApplicationController
	def index 
		@houses = House.all.resources
	end

	def show
		house_uri = resource_uri(params[:id])
		@house = House.find(house_uri)
	end
end
