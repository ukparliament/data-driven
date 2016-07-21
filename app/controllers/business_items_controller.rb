class BusinessItemsController < ApplicationController
	def index
		date = params[:date]
		@order_paper = OrderPaperItem.all(date)

		@json_ld = json_ld(data)
		format(data)
	end

	#rename this method
end