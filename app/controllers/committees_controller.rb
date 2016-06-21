class CommitteesController < ApplicationController
	def index
		data = Committee.all
		@committees = data[:hierarchy]

		format(data)
	end
end