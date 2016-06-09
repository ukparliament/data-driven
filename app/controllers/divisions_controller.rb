class DivisionsController < ApplicationController
	def index
		@divisions = Division.all.resources
	end

	def index_by_house
		house_uri = resource_uri(params[:house_id])
		@house = House.find(house_uri)
		@divisions = Division.find_by_house(house_uri)
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		@concept = Concept.find(concept_uri)
		@divisions = Division.find_by_concept(concept_uri)
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		@person = Person.find(person_uri)
		@divisions = Division.find_by_person(person_uri)

	def show
		division_uri = resource_uri(params[:id])
		p division_uri
		@division = Division.find(division_uri)
	end
end
