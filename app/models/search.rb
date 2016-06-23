class Search < QueryObject
	include Vocabulary

	def self.find(q, filters)
		filterString = ""
		if filters
			filterArray = filters.map do |filterKey, filterValue|
				# TODO: convert to reduce
				"?type = #{filterKey}"
			end

			filterString = "FILTER(#{filterArray.join(" || ")})"
		end

		q = q.gsub(/\"/, "\\\"")

		type_filter = ""

		result_graph = self.query("
			PREFIX luc: <http://www.ontotext.com/owlim/lucene#>
			PREFIX schema: <http://schema.org/>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			 
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
			    FILTER(?property = schema:name || ?property = schema:text || ?property = dcterms:title || ?property = dcterms:description || ?property = rdfs:label)
				#{filterString}
				#FILTER(?type = parl:Division || ?type = parl:OralParliamentaryQuestion || ?type = parl:WrittenParliamentaryQuestion || ?type = parl:WrittenParliamentaryAnswer || ?type = schema:Person || ?type = parl:Committee)
				BIND(xsd:float(?scoreString) AS ?score)
			}
			LIMIT 204
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
				:controller => controller,
				:friendly_type => friendly_type
			}
		end

		{ :graph => result_graph, :hierarchy => hierarchy }
	end
	
end