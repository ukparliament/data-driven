class Person < QueryObject
	include Vocabulary 

  	def self.most_active_people
  			result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
			    ?person
			        schema:name ?name ;
			    	parl:count ?count .
			}
			WHERE { 
			    SELECT ?person ?name (COUNT(?contribution) AS ?count)
			    WHERE {
			        ?person
			            a schema:Person ;
				        schema:name ?name .
			        ?contribution parl:member ?person .
			    }
			    GROUP BY ?person ?name
			    ORDER BY DESC(?count)
			    LIMIT 100
			}
		")

		hierarchy = result.subjects(unique: true).map do |subject| 
			name_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Schema.name, 
		  		:name)
			name = result.first_literal(name_pattern)
			count_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Parl.count, 
		  		:count)
			count = result.first_literal(count_pattern)

			{
				:id => self.get_id(subject),
				:name => name.to_s,
				:count => count.to_i
			}
		end

		{ :graph => result, :hierarchy => hierarchy }

  	end

  	def self.find(uri)
  		result = self.query("
			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
				<#{uri}>
			        schema:name ?name .
			}
			WHERE { 
				<#{uri}> 
					schema:name ?name .
		}")
		
		hierarchy = result.map do |statement| 
      		{
      		  :id => self.get_id(statement.subject),
      		  :name => statement.object.to_s
      		}
    	end.first

		{ :graph => result, :hierarchy => hierarchy }

  	end
  	# def self.ordered_tabling_members_on_subject(concept_uri)
  	# 	Person.find_by_sparql("PREFIX dcterms: <http://purl.org/dc/terms/>
			# 				PREFIX parl: <http://data.parliament.uk/schema/parl#>
			# 				SELECT ?uri
			# 				WHERE {
			# 				    ?question parl:tablingMember ?uri;
			# 				    dcterms:subject <#{concept_uri}> .
			# 				}
			# 				GROUP BY ?uri
			# 				ORDER BY DESC(COUNT(?question))
			# 				LIMIT 100
			# 				")
  	# end

end