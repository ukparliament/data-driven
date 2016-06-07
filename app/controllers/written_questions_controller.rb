class WrittenQuestionsController < ApplicationController
	def index
		@written_questions = WrittenQuestion.all.limit(30).resources 
	end
end
