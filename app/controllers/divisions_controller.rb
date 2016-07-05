class DivisionsController < ApplicationController
	def index
		data = Division.all
		@hierarchy = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_house
		house_uri = resource_uri(params[:house_id])
		data = Division.find_by_house(house_uri)
		@hierarchy = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		data = Division.find_by_concept(concept_uri)
		@hierarchy = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def show
		division_uri = resource_uri(params[:id])
		data = Division.find(division_uri)
		@division = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end
end
