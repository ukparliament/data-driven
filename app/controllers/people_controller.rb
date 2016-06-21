class PeopleController < ApplicationController

	def index
		data = Person.most_active_people
		@people = data[:hierarchy]

		format(data)
	end

	def show
		person_uri = resource_uri(params[:id])
		data = Person.find(person_uri)
		@person = data[:hierarchy]

		format(data)
	end
end
