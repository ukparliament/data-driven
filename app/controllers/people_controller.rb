class PeopleController < ApplicationController

	def index
		@people = Person.most_active_people
	end

	def all
		@people = Person.all.resources
	end

	def show
		person_uri = resource_uri(params[:id])
		@person = Person.find(person_uri)
	end
end
