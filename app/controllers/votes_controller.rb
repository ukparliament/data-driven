class VotesController < ApplicationController
	include Vocabulary

	def index_by_division
		division_uri = resource_uri(params[:division_id])
		data = Vote.find_by_division(division_uri)
		@division = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		data = Vote.find_by_person(person_uri)
		@person = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end
end