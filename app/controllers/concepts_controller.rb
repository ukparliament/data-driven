class ConceptsController < ApplicationController

	def index
		@concepts = Concept.most_popular_by_contribution

		format(@concepts)
	end

	def show
		concept_uri = resource_uri(params[:id])
		@concept = Concept.find(concept_uri)

		format(@concept)
	end
end
