class HousesController < ApplicationController
	def index 
		@houses = House.all.resources
	end
end
