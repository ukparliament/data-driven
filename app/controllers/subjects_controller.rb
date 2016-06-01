class SubjectsController < ApplicationController
	def index
		if(params[:member_id] == nil)
			@subjects = Subject.all.limit(50).resources
		else
			member_uri = "http://data.parliament.uk/resource/#{params[:member_id]}"
			member = Member.find(member_uri)
			@subjects = Subject.find_by_sparql("SELECT DISTINCT ?uri WHERE {?question <http://purl.org/dc/terms/subject> ?uri ;
																    		    	  <http://data.parliament.uk/schema/parl#tablingMember> <#{member_uri}> .} LIMIT 100")
		end
	end
end
