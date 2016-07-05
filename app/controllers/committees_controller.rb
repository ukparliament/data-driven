class CommitteesController < ApplicationController
	def index
		data = Committee.all
		@committees = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

  def show
		committee_uri = resource_uri(params[:id])
		data = Committee.find(committee_uri)
		@committee = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

  def index_by_person
		person_uri = resource_uri(params[:person_id])
		data = Committee.find_by_person(person_uri)
		@committees = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end
end