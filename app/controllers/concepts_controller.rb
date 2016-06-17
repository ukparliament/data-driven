class ConceptsController < ApplicationController

	def index
		data = Concept.most_popular_by_contribution
		@concepts = data[:hierarchy]

		format(data)
	end

	def show
		concept_uri = resource_uri(params[:id])
		data = Concept.find(concept_uri)
		@concept = data[:hierarchy]

		format(data)
	end
end
