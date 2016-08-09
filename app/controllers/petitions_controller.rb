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
		if(request.format.html?)
			redirect_to("http://petitions-data-driven.ukpds.org/concepts/#{params[:concept_id]}/petitions")
			return ''
		end

		concept_uri = resource_uri(params[:concept_id])
		data = Petition.find_by_concept(concept_uri)
		format(data)
	end

	def show
		if(request.format.html?)
			redirect_to("http://petitions-data-driven.ukpds.org/petitions/#{params[:id]}")
			return ''
		end

		petition_uri = resource_uri(params[:id])
		data = Petition.find(petition_uri)

		format(data)
	end

end