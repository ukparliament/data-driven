class OralQuestionsController < ApplicationController

	def index
		@oral_questions = OralQuestion.all.limit(30).resources

		format(@oral_questions)
	end

	def show
		oral_question_uri = resource_uri(params[:id])
		@oral_question = OralQuestion.find(oral_question_uri)
		
		format(@oral_question)
	end

	def index_by_house
		house_uri = resource_uri(params[:house_id])
		@house = House.find(house_uri)
		@oral_questions = OralQuestion.find_by_house(house_uri)
		
		format([@house, @oral_questions])
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		@concept = Concept.find(concept_uri)
		@oral_questions = OralQuestion.find_by_concept(concept_uri)
		
		format([@concept, @oral_questions])
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		@person = Person.find(person_uri)
		@oral_questions = OralQuestion.find_by_person(person_uri)
		
		format([@person, @oral_questions])
	end
end
