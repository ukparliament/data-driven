class WrittenAnswersController < ApplicationController
	def show
		written_answer_uri = resource_uri(params[:id])
		question = WrittenAnswer.find_question(written_answer_uri)

		redirect_to(written_question_path(question[:id]))
	end
end