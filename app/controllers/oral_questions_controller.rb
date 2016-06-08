class OralQuestionsController < ApplicationController

	def index
		@oral_questions = OralQuestion.all.limit(30).resources
	end

	def index_by_house
		house_id = params[:house_id]
		house_uri = "http://data.parliament.uk/resource/#{house_id}"
		@house = House.find(house_uri)
		@oral_questions = OralQuestion.find_by_house(house_uri)
	end

	def index_by_concept
		concept_id = params[:concept_id]
		concept_uri = "http://data.parliament.uk/resource/#{concept_id}"
		@concept = Concept.find(concept_uri)
		@oral_questions = OralQuestion.find_by_concept(concept_uri)
	end
end
