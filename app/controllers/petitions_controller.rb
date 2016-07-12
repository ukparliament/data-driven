class PetitionsController < ApplicationController

	def index
		data = Petition.all
		render json: data[:hierarchy] 
	end

end