class CommitteesController < ApplicationController
	def index
		data = Committee.all
		params[:sort] == "indexed" ? @committees = Committee.sort_indexed(data[:hierarchy]) : @committees = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

  	def show
		committee_uri = resource_uri(params[:id])
		data = Committee.find(committee_uri)
		@committee = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

  	def index_by_person
		person_uri = resource_uri(params[:person_id])
		data = Committee.find_by_person(person_uri)
		@committees = data[:hierarchy]

		@json_ld = json_ld(data)
		format(data)
	end

	def index_by_concept
		concept_uri = resource_uri(params[:concept_id])
		data = Committee.find_by_concept(concept_uri)
		@concept = data[:hierarchy][:concept]
		@committees = data[:hierarchy][:committees]

		@json_ld = json_ld(data)
		format(data)
	end

	def edit
		committee_uri = resource_uri(params[:committee_id])
		data = Committee.find(committee_uri)
		@committee = data[:hierarchy]
		@concepts = concepts_dropdown_list
		@linked_concepts = @committee[:concepts]

		@indexed_status = @committee[:index_label] == "indexed"
		@junk_status = @committee[:junk_label] == "junk"

		@json_ld = json_ld(data)
		format(data)
	end

	def update
		committee_id = params[:committee_id]

		if params[:remove]
			index_junk_check(committee_id)
			if params[:linked_concepts]
				remove_concepts(committee_id, params[:linked_concepts])
			end
			redirect_to committee_edit_path(committee_id)
		end

		if params[:commit]
			index_junk_check(committee_id)
			add_concept(committee_id, params[:concept])
			redirect_to committee_edit_path(committee_id)
		end

		if params[:update]
			index_junk_check(committee_id)
			redirect_to committee_edit_path(committee_id)			
		end
	end

end