class VotesController < ApplicationController

	def index_by_division
		division_uri = resource_uri(params[:division_id])
		@data = Vote.find_by_division(division_uri)

		format(@data)
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		@data = Vote.find_by_person(person_uri)

		format(@data)
	end
end