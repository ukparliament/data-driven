class PetitionsController < ApplicationController

	def index
		if(request.format.html?)
			redirect_to('http://petitions-data-driven.ukpds.org/petitions')
			return ''
		end

		data = Petition.all

		format(data)
	end

	def index_by_concept
		
	end

	def show
		if(request.format.html?)
			redirect_to("http://petitions-data-driven.ukpds.org/constituencies/#{params[:id]}")
			return ''
		end

		petition_uri = resource_uri(params[:id])
		data = Petition.find(petition_uri)

		format(data)
	end

end