class OrderPapersController < ApplicationController

	def index	
    	data = OrderPaper.all
		@order_papers = data[:hierarchy]

		@json_ld = json_ld(data)
    	format(data)
	end
	
end