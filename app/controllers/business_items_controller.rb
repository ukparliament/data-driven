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
		business_item_uri = resource_uri(params[:id])
		dropdown_data = Concept.all_alphabetical
		@concepts = dropdown_data[:hierarchy].map { |concept| [ concept[:label], concept[:id] ]}.to_h

		data = Concept.find_by_business_item(business_item_uri)
		@linked_concepts = data[:hierarchy][:concepts]
		@business_item_title = data[:hierarchy][:business_item_title]

		@json_ld = json_ld(data)
		format(data)
	end

	def update
		if params[:remove]
			concept_id = params[:remove]
			item_id = params[:id]
			repo = SPARQL::Client::Repository.new('http://graphdbtest.eastus.cloudapp.azure.com/repositories/DataDriven06/statements')
			client = repo.client

			s = RDF::URI.new("http://id.ukpds.org/#{item_id}")
			p = RDF::URI.new("http://purl.org/dc/terms/subject")
			o = RDF::URI.new("http://id.ukpds.org/#{concept_id}")
			statement = RDF::Statement(s, p, o)
			graph = RDF::Graph.new << statement

			results = client.delete_data(graph)
			redirect_to order_paper_business_item_edit_path(params[:order_paper_id], params[:id])
		end

		if params[:commit]
			concept_id = params[:concept]
			item_id = params[:id]
			repo = SPARQL::Client::Repository.new('http://graphdbtest.eastus.cloudapp.azure.com/repositories/DataDriven06/statements')
			client = repo.client

			s = RDF::URI.new("http://id.ukpds.org/#{item_id}")
			p = RDF::URI.new("http://purl.org/dc/terms/subject")
			o = RDF::URI.new("http://id.ukpds.org/#{concept_id}")
			statement = RDF::Statement(s, p, o)
			graph = RDF::Graph.new << statement

			results = client.insert_data(graph)
			redirect_to order_paper_business_item_edit_path(params[:order_paper_id], params[:id])
		end
	end
end