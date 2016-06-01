class SubjectsController < ApplicationController
	def index
		@subjects = Subject.all.limit(50).resources
	end

	def show
		subject_id = params[:id]
		subject_uri = "http://data.parliament.uk/resource/#{subject_id}"
		@subject = Subject.find(subject_uri)
		@members = Member.find_by_sparql("SELECT DISTINCT ?uri WHERE {?question <http://data.parliament.uk/schema/parl#tablingMember> ?uri ;
																    		    <http://purl.org/dc/terms/subject> <#{subject_uri}> .} LIMIT 100")
	end
end
