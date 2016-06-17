class OralQuestionsController < ApplicationController

	def index
		data = OralQuestion.all
		@oral_questions = data[:hierarchy]

		format(data)
	end

	def show
		oral_question_uri = resource_uri(params[:id])
		data = OralQuestion.find(oral_question_uri)
		@oral_question = data[:hierarchy]
		
		format(data)
	end

	def index_by_house
		house_uri = resource_uri(params[:house_id])
		data = OralQuestion.find_by_house(house_uri)
		@hierarchy = data[:hierarchy]
		
		format(data)
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		data = OralQuestion.find_by_concept(concept_uri)
		@hierarchy = data[:hierarchy]
		
		format(data)
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		data = OralQuestion.find_by_person(person_uri)
		@hierarchy = data[:hierarchy]
		
		format(data)
	end
end
