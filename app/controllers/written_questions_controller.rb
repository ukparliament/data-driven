class WrittenQuestionsController < ApplicationController

	def index
		data = WrittenQuestion.all
		@hierarchy = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def show
		written_question_uri = resource_uri(params[:id])
		data = WrittenQuestion.find(written_question_uri)
		@written_question = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_house
		house_uri = resource_uri(params[:house_id])
		data = WrittenQuestion.find_by_house(house_uri)
		@hierarchy = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		data = WrittenQuestion.find_by_concept(concept_uri)
		@hierarchy = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		data = WrittenQuestion.find_by_person(person_uri)
		@hierarchy = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end
end
