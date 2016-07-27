class SearchController < ApplicationController
	def index
		if params[:filters] == nil
			params[:filters] = {}
			params[:filters]["parl:Division"] = "on"
			params[:filters]["parl:OralParliamentaryQuestion"] = "on"
			params[:filters]["parl:WrittenParliamentaryQuestion"] = "on"
			params[:filters]["parl:WrittenParliamentaryAnswer"] = "on"
			params[:filters]["parl:Committee"] = "on"
			params[:filters]["schema:Person"] = "on"
			params[:filters]["parl:OrderPaperItem"] = "on"
		end
		
		data = Search.find(params[:q], params[:filters])
		@results = data[:hierarchy]

		format(data)
	end
end