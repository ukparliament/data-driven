class WrittenQuestionsController < ApplicationController

	def index
		if(params[:house_id] != nil)
			house_id = params[:house_id]
			house_uri = "http://data.parliament.uk/resource/#{house_id}"
			@house = House.find(house_uri)
			@written_questions = WrittenQuestion.find_by_house(house_uri)
			render 'index_by_house'
		else
			@written_questions = WrittenQuestion.all.limit(30).resources
		end
	end
end
