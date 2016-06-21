class DivisionsController < ApplicationController
	def index
		data = Division.all
		@divisions = data[:hierarchy]

		format(data)
	end

	def index_by_house
		house_uri = resource_uri(params[:house_id])
		@house = House.find(house_uri)
		@divisions = Division.find_by_house(house_uri)

		format([@house, @divisions])
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		@concept = Concept.find(concept_uri)
		@divisions = Division.find_by_concept(concept_uri)
		
		format([@concept, @divisions])
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		@person = Person.find(person_uri)
		@divisions = Division.find_by_person(person_uri)
		
		format([@person, @divisions])
	end

	def show
		division_uri = resource_uri(params[:id])
		@division = Division.find(division_uri)

		format(@division)
	end
end
