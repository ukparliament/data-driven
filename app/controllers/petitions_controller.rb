class PetitionsController < ApplicationController

	def index
		data = Petition.all

		format(data)
	end

	def show
		petition_uri = resource_uri(params[:id])
		data = Petition.find(petition_uri)

		format(data)
	end

end