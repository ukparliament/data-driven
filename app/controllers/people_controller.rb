class PeopleController < ApplicationController

	def index
		@people = Person.all.resources
	end

	def show
		person_id = params[:id]
		person_uri = "http://data.parliament.uk/resource/#{person_id}"
		@person = Person.find(person_uri)
		@subjects = Concept.find_by_sparql("SELECT DISTINCT ?uri WHERE {?question <http://purl.org/dc/terms/subject> ?uri ;
																    		      <http://data.parliament.uk/schema/parl#tablingMember> <#{person_uri}> .} LIMIT 100")
	end
end
