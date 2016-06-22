class CommitteesController < ApplicationController
	def index
		data = Committee.all
		@committees = data[:hierarchy]

		format(data)
	end

  def show
		committe_uri = resource_uri(params[:id])
		data = Committee.find(committe_uri)
		@committee = data[:hierarchy]

		format(data)
	end
end