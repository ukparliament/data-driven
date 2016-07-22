class BusinessItemsController < ApplicationController
	def index
		date = params[:order_paper_id]
		data = BusinessItem.all(date)
		@order_paper = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def show
		business_item_uri = resource_uri(params[:id])
		data = BusinessItem.find(business_item_uri)
		@business_item = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

end