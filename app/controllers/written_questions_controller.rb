class WrittenQuestionsController < ApplicationController

	def index
		@written_questions = WrittenQuestion.all.limit(30).resources
	end

	def show
		written_question_uri = resource_uri(params[:id])
		@written_question = WrittenQuestion.find(written_question_uri)
	end

	def index_by_house
		house_uri = resource_uri(params[:house_id])
		@house = House.find(house_uri)
		@written_questions = WrittenQuestion.find_by_house(house_uri)
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		@concept = Concept.find(concept_uri)
		@written_questions = WrittenQuestion.find_by_concept(concept_uri)
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		@person = Person.find(person_uri)
		@written_questions = WrittenQuestion.find_by_person(person_uri)
	end
end
