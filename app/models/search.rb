class Search < QueryObject
	include Vocabulary

	def self.find(q, filters)
		if filters
			filterString = filters.inject("FILTER(") do |sum, (k, v)| 
				sum += "?type = #{k}" 
				sum += k == filters.keys.last ? ")" : " || "
			end
		end

		q = q.gsub(/\"/, "\\\"")

		result_graph = self.query("
			PREFIX luc: <http://www.ontotext.com/owlim/lucene#>
			PREFIX schema: <http://schema.org/>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
			 
			CONSTRUCT {
			    ?result
			        a ?type ;
			        parl:score ?score ;
			    	?property ?text ;
			    	dcterms:date ?date .
			}
			WHERE { 
				SELECT ?result ?type ?score ?property ?text ?date
				WHERE {
					?result 
			    		a ?type ;
			        	luc:searchAll \"#{q}\" ;
			        	luc:score ?scoreString ;
			        	?property ?text .
			    	FILTER(?property = schema:name || ?property = schema:text || ?property = dcterms:title || ?property = dcterms:description || ?property = rdfs:label || ?property = skos:prefLabel)
					#{filterString}
					#FILTER(?type = parl:Division || ?type = parl:OralParliamentaryQuestion || ?type = parl:WrittenParliamentaryQuestion || ?type = parl:WrittenParliamentaryAnswer || ?type = schema:Person || ?type = parl:Committee)
					BIND(xsd:float(?scoreString) AS ?score)
					OPTIONAL {
						?result dcterms:date ?date .
					}
				}
				ORDER BY DESC(?score)
				LIMIT 204
			}
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
				when Parl.Committee
					Schema.name
				when Skos.Concept
					Skos.prefLabel
				when Parl.OrderPaperItem
					Dcterms.title
				end

			controller = 
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
				when Parl.Committee
					"committees"
				when Skos.Concept
					"concepts"
				when Parl.OrderPaperItem
					"order_paper_items"
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
				when Parl.Committee
					"Committee"
				when Skos.Concept
					"Concept"
				when Parl.OrderPaperItem
					"Order Paper Item"
				end

			text_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(result.subject),
				text_property,
				:text)

			text = result_graph.first_literal(text_pattern)

			date_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(result.subject),
				Dcterms.date,
				:date
				)

			date = result_graph.first_literal(date_pattern)

			{
				:id => id,
				:type => type.to_s,
				:score => score.to_f,
				:text => text.to_s,
				:controller => controller,
				:friendly_type => friendly_type,
				:date => date.to_s.to_datetime
			}
		end

		{ :graph => result_graph, :hierarchy => hierarchy }
	end
	
end