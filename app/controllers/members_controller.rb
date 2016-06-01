class MembersController < ApplicationController
	def index
		if(params[:subject_id] == nil)
			@members = Member.all.resources
		else
			subject_uri = "http://data.parliament.uk/resource/#{params[:subject_id]}"
			subject = Subject.find(subject_uri)
			@members = Member.find_by_sparql("SELECT DISTINCT ?uri WHERE {?question <http://data.parliament.uk/schema/parl#tablingMember> ?uri ;
															    		    	<http://purl.org/dc/terms/subject> <#{subject_uri}> .} LIMIT 100")
		end
	end
end
