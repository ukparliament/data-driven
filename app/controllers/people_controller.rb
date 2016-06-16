class PeopleController < ApplicationController

	def index
		@people = Person.most_active_people

		format(@people)
	end

	def show
		person_uri = resource_uri(params[:id])
		@person = Person.find(person_uri)

		format(@person)
	end
end
