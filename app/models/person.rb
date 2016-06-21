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
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			CONSTRUCT {
				<#{uri}>
			        schema:name ?name ;
			        parl:house ?house .
			    ?house
			    	rdfs:label ?label .
			}
			WHERE { 
				<#{uri}> 
					schema:name ?name ;
					parl:house ?house .
				?house
			    	rdfs:label ?label .
		}")

		name_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Schema.name,
			:name)
		house_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.house,
			:house)

		name = result.first_literal(name_pattern)
		house = result.first_object(house_pattern)

		house_label_pattern = RDF::Query::Pattern.new(
			house,
			Rdfs.label,
			:label)
		label = result.first_literal(house_label_pattern)

		hierarchy = 
      		{
      		  :id => self.get_id(uri),
      		  :name => name.to_s,
      		  :house => {
      		  	:id => self.get_id(house),
      		  	:label => label.to_s
      		  }
      		}

		{ :graph => result, :hierarchy => hierarchy }

  	end
end