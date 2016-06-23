class SearchController < ApplicationController
	def index
		data = Search.find(params[:q], params[:filters])
		@results = data[:hierarchy]

		format(data)
	end
end