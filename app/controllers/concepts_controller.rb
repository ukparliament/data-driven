class ConceptsController < ApplicationController

	def index
		data = Concept.most_popular_by_contribution

		@concepts = data[:hierarchy]
		format(data)
	end

	def show
		concept_uri = resource_uri(params[:id])
		@concept = Concept.find(concept_uri)

		format(@concept)
	end
end
