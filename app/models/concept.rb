class Concept < QueryObject
	include Vocabulary
	
	def self.most_popular_by_contribution
		result = self.query("
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			CONSTRUCT {
			    ?concept
			        skos:prefLabel ?label ;
			    	parl:count ?count .
			}
			WHERE { 
			    SELECT ?concept ?label (COUNT(?contribution) AS ?count)
			    WHERE {
			        ?concept
			            a skos:Concept ;
				        skos:prefLabel ?label .
			        ?contribution dcterms:subject ?concept .
			    }
			    GROUP BY ?concept ?label
			    ORDER BY DESC(?count)
			    LIMIT 50
			}
		")

	  	hierarchy = self.all_convert_to_hash(result)

		{ :graph => result, :hierarchy => hierarchy }
	end

	def self.find(uri)
		result = self.query("
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
			CONSTRUCT {
				<#{uri}>
			        skos:prefLabel ?label ;
			}
			WHERE { 
				<#{uri}> 
					skos:prefLabel ?label .
		}")
		
		hierarchy = self.find_convert_to_hash(result).first

		{ :graph => result, :hierarchy => hierarchy }
	end


  # def self.most_popular_by_question_for_tabling_member(person_uri)
  # 	Concept.find_by_sparql("PREFIX dcterms: <http://purl.org/dc/terms/>
		# 				PREFIX parl: <http://data.parliament.uk/schema/parl#>
		# 				SELECT ?uri
		# 				WHERE {
		# 				    ?question dcterms:subject ?uri;
		# 				    parl:tablingMember <#{person_uri}> .
		# 				}
		# 				GROUP BY ?uri
		# 				ORDER BY DESC(COUNT(?question))
		# 				LIMIT 100
		# 				")
  # end

	private

	def self.all_convert_to_hash(graph)
		graph.subjects(unique: true).map do |subject| 
			label_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Skos.prefLabel, 
		  		:label)
			label = graph.first_literal(label_pattern)
			count_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Parl.count, 
		  		:count)
			count = graph.first_literal(count_pattern)

			{
				:id => self.get_id(subject),
				:label => label.to_s,
				:count => count.to_i
			}
		end
	end

	def self.find_convert_to_hash(graph)
		graph.map do |statement| 
      		{
      		  :id => self.get_id(statement.subject),
      		  :label => statement.object.to_s
      		}
    	end
	end
end