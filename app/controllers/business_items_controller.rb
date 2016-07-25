require 'net/http'

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

	def edit
		repo = SPARQL::Client::Repository.new('http://graphdbtest.eastus.cloudapp.azure.com/repositories/test/statements')
		client = repo.client

		# client = SPARQL::Client.new('http://graphdbtest.eastus.cloudapp.azure.com/repositories/test/statements')

		# sparql = 'update'
		# results = client.delete_data('<http://id.ukpds.org/23a6596b-bc6c-4577-a9d7-0670fcdfe180> <http://purl.org/dc/terms/subject> <http://id.ukpds.org/00091072-0000-0000-0000-000000000002> .')

		s = RDF::URI.new('http://id.ukpds.org/23a6596b-bc6c-4577-a9d7-0670fcdfe180')
		p = RDF::URI.new('http://purl.org/dc/terms/subject')
		o = RDF::URI.new('http://id.ukpds.org/00091072-0000-0000-0000-000000000002')
		statement = RDF::Statement(s, p, o)
		graph = RDF::Graph.new << statement
		results = client.delete_data(graph)

		render text: results
	end

end