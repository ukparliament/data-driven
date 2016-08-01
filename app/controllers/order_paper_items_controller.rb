require 'net/http'

class OrderPaperItemsController < ApplicationController
	def index
		data = OrderPaperItem.all
		@order_paper_items = data[:hierarchy][:order_paper_items]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_order_paper
		date = params[:order_paper_id]
		data = OrderPaperItem.all_by_date(date)
		@order_paper = data[:hierarchy]
		@order_paper_items = data[:hierarchy][:order_paper_items]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		data = OrderPaperItem.find_by_concept(concept_uri)
		@concept = data[:hierarchy]
		@order_paper_items = data[:hierarchy][:order_paper_items]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		data = OrderPaperItem.find_by_person(person_uri)
		@person = data[:hierarchy]
		@order_paper_items = data[:hierarchy][:order_paper_items]

		@json_ld = json_ld(data)
		format(data)
	end

	def show
		order_paper_item_uri = resource_uri(params[:id])
		data = OrderPaperItem.find(order_paper_item_uri)
		@order_paper_item = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def edit
		order_paper_item_uri = resource_uri(params[:order_paper_item_id])
		dropdown_data = Concept.all_alphabetical
		@concepts = dropdown_data[:hierarchy].map { |concept| [ concept[:label], concept[:id] ]}.to_h

		data = OrderPaperItem.find(order_paper_item_uri)
		@order_paper_item = data[:hierarchy]
		@indexed_status = @order_paper_item[:index_label] == "indexed"

		@json_ld = json_ld(data)
		format(data)
	end

	def update
		if params[:remove]
			index_check
			if params[:linked_concepts]
				concept_ids = params[:linked_concepts]
				item_id = params[:order_paper_item_id]
				concept_ids.each do |concept_id|
					update_graph(item_id, 'http://purl.org/dc/terms/subject', rdf_uri(concept_id), false)
				end
			end
			redirect_to order_paper_item_edit_path(params[:order_paper_item_id])
		end

		if params[:commit]
			index_check
			concept_id = params[:concept]
			item_id = params[:order_paper_item_id]
			update_graph(item_id, 'http://purl.org/dc/terms/subject', rdf_uri(concept_id), true)

			redirect_to order_paper_item_edit_path(params[:order_paper_item_id])
		end

		if params[:update_index]
			index_check
			redirect_to order_paper_item_edit_path(params[:order_paper_item_id])
		end
	end

	private 

	def update_graph(subject_id, predicate, object, is_insert)
		repo = SPARQL::Client::Repository.new("#{DataDriven::Application.config.database}/statements")		
		client = repo.client
		graph = RDF::Graph.new << create_pattern(subject_id, predicate, object)
		is_insert == true ? client.insert_data(graph) : client.delete_data(graph)
	end

	def create_pattern(subject_id, predicate, object)
		s = RDF::URI.new("http://id.ukpds.org/#{subject_id}")
		p = RDF::URI.new("#{predicate}")
		o = object
		RDF::Statement(s, p, o)
	end

	def index_check
		item_id = params[:order_paper_item_id]
		if params[:index_checked]
			update_graph(item_id, 'http://data.parliament.uk/schema/parl#indexed', 'indexed', true)
		else
			update_graph(item_id, 'http://data.parliament.uk/schema/parl#indexed', 'indexed', false)
		end
	end
end