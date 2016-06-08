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
		@subjects = Concept.most_popular_by_question_for_tabling_member(person_uri)
	end

end
