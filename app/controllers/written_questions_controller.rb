class WrittenQuestionsController < ApplicationController

	def index
		@written_questions = WrittenQuestion.all.limit(30).resources
	end

	def show
		written_question_id = params
		written_question_uri = "http://data.parliament.uk/resource/#{written_question_id}"
		@written_question = WrittenQuestion.find(written_question_uri)
	end

	def index_by_house
		house_id = params[:house_id]
		house_uri = "http://data.parliament.uk/resource/#{house_id}"
		@house = House.find(house_uri)
		@written_questions = WrittenQuestion.find_by_house(house_uri)
	end

	def index_by_concept
		concept_id = params[:concept_id]
		concept_uri = "http://data.parliament.uk/resource/#{concept_id}"
		@concept = Concept.find(concept_uri)
		@written_questions = WrittenQuestion.find_by_concept(concept_uri)
	end
end
