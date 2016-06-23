class PeopleController < ApplicationController

	def index
		data = Person.most_active_people
		@people = data[:hierarchy]

		format(data)
	end

	def index_by_house
		house_uri = resource_uri(params[:house_id])
		data = Person.find_most_active_by_house(house_uri)
		@house = data[:hierarchy]
		p house_uri
		format(data)
	end

	def show
		person_uri = resource_uri(params[:id])
		data = Person.find(person_uri)
		@person = data[:hierarchy]

		format(data)
	end
	
end
