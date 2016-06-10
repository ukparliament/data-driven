class VotesController < ApplicationController

	def index_by_division
		division_uri = resource_uri(params[:division_id])
		@division = Division.find(division_uri)
		@votes = Vote.find_by_division(division_uri)
	end

end