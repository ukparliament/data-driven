class HousesController < ApplicationController
	def index 
		@houses = House.all.resources
	end

	def show
		house_id = params[:id]
		house_uri = "http://data.parliament.uk/resource/#{house_id}"
		@house = House.find(house_uri)
		@oral_questions_by_house = OralQuestion.find_by_house(house_uri)[0..2]
		@written_questions_by_house = WrittenQuestion.find_by_house(house_uri)[0..2]
		@divisions_by_house = Division.find_by_house(house_uri)[0..2]
	end
end
