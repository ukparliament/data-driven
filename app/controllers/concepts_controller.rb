class ConceptsController < ApplicationController

	def index
		data = Concept.most_popular_by_contribution
		@concepts = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def show
		concept_uri = resource_uri(params[:id])
		data = Concept.find(concept_uri)
		@concept = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end
end
