class PetitionsController < ApplicationController

	def index
		data = Petition.all

		render json: data[:hierarchy] 
	end

	def show
		petition_uri = resource_uri(params[:id])
		data = Petition.find(petition_uri)

		render json: data[:hierarchy]
	end

end