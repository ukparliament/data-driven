class PeopleController < ApplicationController

	def index
		data = Person.most_active_people
		@hierarchy = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_house
		house_uri = resource_uri(params[:house_id])
		data = Person.find_most_active_by_house(house_uri)
		@hierarchy = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def show
		person_uri = resource_uri(params[:id])
		data = Person.find(person_uri)
		@person = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end
	
end
