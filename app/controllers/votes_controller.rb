class VotesController < ApplicationController

	def index_by_division
		division_uri = resource_uri(params[:division_id])
		@division = Division.find(division_uri)
		@votes = @division.votes
	end

end