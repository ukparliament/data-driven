class SearchController < ApplicationController
	def index
		data = Search.find(params[:q])
		@results = data[:hierarchy]

		format(data)
	end
end