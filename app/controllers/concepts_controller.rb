class ConceptsController < ApplicationController

	def index
		@concepts = Concept.most_popular_by_question
	end

	def all
		@concepts = Concept.all.limit(50).resources
	end

	def show
		concept_id = params[:id]
		concept_uri = "http://data.parliament.uk/resource/#{concept_id}"
		@concept = Concept.find(concept_uri)
		@tabling_members = Person.find_by_sparql("SELECT DISTINCT ?uri WHERE {?question <http://data.parliament.uk/schema/parl#tablingMember> ?uri ;
																    		    <http://purl.org/dc/terms/subject> <#{concept_uri}> .} LIMIT 100")
	end
end
