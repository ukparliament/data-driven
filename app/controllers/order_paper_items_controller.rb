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
		params[:sort] == "indexed" ? @order_paper_items = OrderPaperItem.sort_indexed(data[:hierarchy][:order_paper_items]) : 
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
		@concepts = concepts_dropdown_list
		data = OrderPaperItem.find(order_paper_item_uri)
		@order_paper_item = data[:hierarchy]
		@indexed_status = @order_paper_item[:index_label] == "indexed"
		@junk_status = @order_paper_item[:junk_label] == "junk"
		@business_item_type = @order_paper_item[:business_item_type]
		@member_role = @order_paper_item[:person][:role]
		@linked_concepts = @order_paper_item[:concepts]

		@json_ld = json_ld(data)
		format(data)
	end

	def update
		item_id = params[:order_paper_item_id]
		if params[:remove]
			update_business_item(item_id)
			if params[:linked_concepts]
				remove_concepts(item_id, params[:linked_concepts])
			end
			redirect_to order_paper_item_edit_path(item_id)
		end

		if params[:commit]
			update_business_item(item_id)
			add_concept(item_id, params[:concept])

			redirect_to order_paper_item_edit_path(item_id)
		end

		if params[:update]
			update_business_item(item_id)
			redirect_to order_paper_item_edit_path(item_id)
		end
	end

	private 

	def update_business_item(item_id)
		index_junk_check(item_id)
		business_item_type_update(item_id)
		member_role_update(item_id)
		title_update(item_id)
	end

	def business_item_type_update(item_id)
		current_business_item_type = params[:current_business_item_type]
		new_business_item_type = params[:new_business_item_type]
		update_graph(item_id, Parl.businessItemType, current_business_item_type, false) 
		update_graph(item_id, Parl.businessItemType, new_business_item_type, true) unless new_business_item_type == "" 
	end

	def member_role_update(item_id)
		if params[:current_member_role]
			current_role = params[:current_member_role]
			new_role = params[:new_member_role]
			update_graph(item_id, Parl.memberRole, current_role, false) 
			update_graph(item_id, Parl.memberRole, new_role, true) unless new_role == ""
		end
	end

	def title_update(item_id)
		current_title = params[:current_title]
		new_title = params[:new_title]
		if(current_title != new_title && new_title != "")
			update_graph(item_id, Dcterms.title, current_title, false) 
			update_graph(item_id, Dcterms.title, new_title, true) unless new_title == ""
		end
	end
end