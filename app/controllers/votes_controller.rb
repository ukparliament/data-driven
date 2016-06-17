class VotesController < ApplicationController
	include Vocabulary

	def index_by_division
		division_uri = resource_uri(params[:division_id])
		@data = Vote.find_by_division(division_uri)

		format(@data)
	end

	def index_by_person
		person_uri = resource_uri(params[:person_id])
		triples = Vote.find_by_person(person_uri)
		graph = RDF::Graph.new
		graph << triples

		person_name_pattern = RDF::Query::Pattern.new(
		  RDF::URI.new(person_uri), 
		  Schema.name, 
		  :person_name)
		vote_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  Parl.voteValue, 
		  :vote_value)

		 @person_name = graph.first_value(person_name_pattern)

		 @votes = graph.query(vote_pattern).map do |vote_statement|
			division_title_pattern = RDF::Query::Pattern.new(
				vote_statement.subject, 
				Parl.divisionTitle, 
				:division_title)
			division_pattern = RDF::Query::Pattern.new(
				vote_statement.subject, 
				Parl.division, 
				:division)

			division_id = graph.first_object(division_pattern).to_s.split('/').last
		 	division_title = graph.first_value(division_title_pattern)
		 	vote_text = vote_statement.object == true ? 'Content' : 'Not content' 

			{
				:value => vote_text,
				:division_title => division_title,
				:division_id => division_id
			}
		 end

		 format([@person_name, @votes])
	end
end