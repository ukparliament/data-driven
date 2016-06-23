class Search < QueryObject
	include Vocabulary

	def self.find(q)
		result_graph = self.query("
			PREFIX luc: <http://www.ontotext.com/owlim/lucene#>
			PREFIX schema: <http://schema.org/>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			 
			CONSTRUCT {
			    ?result
			        a ?type ;
			        parl:score ?score ;
			    	?property ?text .
			}
			WHERE { 
			    ?result 
			    	a ?type ;
			        luc:searchAll \"#{q}\" ;
			        luc:score ?scoreString ;
			        ?property ?text .
			    FILTER(?property = schema:name || ?property = schema:text || ?property = dcterms:title || ?property = dcterms:description)
				BIND(xsd:float(?scoreString) AS ?score)
			}
			LIMIT 100
		")

		search_results_pattern = RDF::Query::Pattern.new(
			:search_result,
			Rdf.type,
			:type)
		search_results = result_graph.query(search_results_pattern)

		hierarchy = search_results.map do |result| 
			type_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(result.subject),
				Rdf.type,
				:type)

			score_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(result.subject),
				Parl.score,
				:score)

			id = self.get_id(result.subject)
			type = result_graph.first_object(type_pattern)
			score = result_graph.first_object(score_pattern)

			text_property = 
				case type
				when Schema.Person
					Schema.name
				when Parl.OralParliamentaryQuestion
					Schema.text
				when Parl.WrittenParliamentaryQuestion
					Schema.text
				when Parl.WrittenParliamentaryAnswer
					Schema.text
				when Parl.Division
					Dcterms.title
				end
			path = 
				case type
				when Schema.Person
					"people"
				when Parl.OralParliamentaryQuestion
					"oral_questions"
				when Parl.WrittenParliamentaryQuestion
					"written_questions"
				when Parl.WrittenParliamentaryAnswer
					"written_answers"
				when Parl.Division
					"divisions"
				end
			friendly_type = 
				case type
				when Schema.Person
					"Person"
				when Parl.OralParliamentaryQuestion
					"Oral Question"
				when Parl.WrittenParliamentaryQuestion
					"Written Question"
				when Parl.WrittenParliamentaryAnswer
					"Written Answer"
				when Parl.Division
					"Division"
				end

			text_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(result.subject),
				text_property,
				:text)

			text = result_graph.first_literal(text_pattern)

			{
				:id => id,
				:type => type.to_s,
				:score => score.to_f,
				:text => text.to_s,
				:path => path,
				:friendly_type => friendly_type
			}
		end

		{ :graph => result_graph, :hierarchy => hierarchy }
	end
	
end