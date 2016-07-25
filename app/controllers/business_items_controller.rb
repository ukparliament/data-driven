require 'net/http'

class BusinessItemsController < ApplicationController
	def index_by_order_paper
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
		data = Concept.all_alphabetical
		@concepts = data[:hierarchy].map { |concept| [ concept[:label], concept[:id] ]}.to_h

		# repo = SPARQL::Client::Repository.new('http://graphdbtest.eastus.cloudapp.azure.com/repositories/test/statements')
		# client = repo.client

		# s = RDF::URI.new('http://id.ukpds.org/23a6596b-bc6c-4577-a9d7-0670fcdfe180')
		# s1 = RDF::URI.new('http://id.ukpds.org/80916328-918f-4efc-b467-4829ad172121')
		# p = RDF::URI.new('http://purl.org/dc/terms/subject')
		# o = RDF::URI.new('http://id.ukpds.org/00091072-0000-0000-0000-000000000002')
		# statement = RDF::Statement(s, p, o)
		# statement1 = RDF::Statement(s1, p, o)
		# graph = RDF::Graph.new << statement
		# graph1 = RDF::Graph.new << statement1
		# results = client.delete_data(graph)
		# results = client.insert_data(graph)
		# results = client.delete_insert(graph, graph1)

		# render text: results
	end

	def update
		if params[:x]
			
			raise params[:x]
		end

		concept_id = params[:concept]
		item_id = params[:id]
		repo = SPARQL::Client::Repository.new('http://graphdbtest.eastus.cloudapp.azure.com/repositories/test/statements')
		client = repo.client

		s = RDF::URI.new("http://id.ukpds.org/#{item_id}")
		p = RDF::URI.new("http://purl.org/dc/terms/subject")
		o = RDF::URI.new("http://id.ukpds.org/#{concept_id}")
		statement = RDF::Statement(s, p, o)
		graph = RDF::Graph.new << statement

		results = client.insert_data(graph)

		raise "#{results}"
	end
end