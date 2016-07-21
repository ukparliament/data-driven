class BusinessItemsController < ApplicationController
	def index_by_date
		date = params[:date]
		@order_paper = OrderPaperItem.find_by_date(date)

		@json_ld = json_ld(data)
		format(data)
	end

	#rename this method
end