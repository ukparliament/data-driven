class WrittenAnswersController < ApplicationController
	def index_by_person
		person_uri = resource_uri(params[:person_id])
		data = WrittenAnswer.find_by_person(person_uri)
		@person = data[:hierarchy]

		format(data)
	end

	def show
		written_answer_uri = resource_uri(params[:id])
		question = WrittenAnswer.find_question(written_answer_uri)

		redirect_to(written_question_path(question[:id]))
	end
	
end