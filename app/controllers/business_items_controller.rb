require 'net/http'

class BusinessItemsController < ApplicationController
	def index_by_order_paper
		date = params[:order_paper_id]
		data = BusinessItem.all(date)
		@order_paper = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		data = BusinessItem.find_by_concept(concept_uri)
		@concept = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		data = BusinessItem.find_by_person(person_uri)
		@person = data[:hierarchy]

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
		@business_item = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def update
		repo = SPARQL::Client::Repository.new("#{DataDriven::Application.config.database}/statements")		
		client = repo.client

		if params[:remove]
			concept_id = params[:remove]
			item_id = params[:id]

			graph = update_pattern(item_id, concept_id)

			client.delete_data(graph)
			redirect_to order_paper_business_item_edit_path(params[:order_paper_id], params[:id])
		end

		if params[:commit]
			concept_id = params[:concept]
			item_id = params[:id]

			graph = update_pattern(item_id, concept_id)

			client.insert_data(graph)
			redirect_to order_paper_business_item_edit_path(params[:order_paper_id], params[:id])
		end
	end

	private 

	def update_pattern(item_id, concept_id)
		s = RDF::URI.new("http://id.ukpds.org/#{item_id}")
		p = RDF::URI.new("http://purl.org/dc/terms/subject")
		o = RDF::URI.new("http://id.ukpds.org/#{concept_id}")
		statement = RDF::Statement(s, p, o)
		RDF::Graph.new << statement
	end
end