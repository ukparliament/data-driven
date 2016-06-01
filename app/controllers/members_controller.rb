class MembersController < ApplicationController

	def index
		@members = Member.all.resources
	end

	def show
		member_id = params[:id]
		member_uri = "http://data.parliament.uk/resource/#{member_id}"
		@member = Member.find(member_uri)
		@subjects = Subject.find_by_sparql("SELECT DISTINCT ?uri WHERE {?question <http://purl.org/dc/terms/subject> ?uri ;
																    		      <http://data.parliament.uk/schema/parl#tablingMember> <#{member_uri}> .} LIMIT 100")
	end
end
