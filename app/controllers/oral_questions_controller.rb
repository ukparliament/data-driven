class OralQuestionsController < ApplicationController
	def index
		@oral_questions = OralQuestion.all.limit(30).resources 
	end
end
