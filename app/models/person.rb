class Person < QueryObject
	include Vocabulary 

  	def self.most_active_people
  			result = self.query('
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
				')

		people = result.subjects(unique: true).map do |subject| 
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

		hierarchy = {
			:people => people
		}

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

  	def self.find_most_active_by_house(house_uri)
  		result = self.query("
  			PREFIX parl: <http://data.parliament.uk/schema/parl#>
      		PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      		PREFIX schema: <http://schema.org/>
      		CONSTRUCT {
      		   ?person 
      		     	schema:name ?name ;
    			   	parl:count ?count .
      		   <#{house_uri}> 
      		     	rdfs:label ?label .
      		}
      		WHERE { 
    			SELECT ?person ?name ?label (COUNT(?contribution) AS ?count)
    				WHERE {
      		  			<#{house_uri}> 
      		  				rdfs:label ?label .
      		   			?person 
      		   				a schema:Person;
      		   			  	parl:house <#{house_uri}>;
      		   			  	schema:name ?name .
      		  			?contribution 
      		  				parl:member ?person .
      				}
				GROUP BY ?person ?name ?label
				ORDER BY DESC(?count)
				LIMIT 100
			}")

  		person_pattern = RDF::Query::Pattern.new(
  			:person,
  			Schema.name,
  			:name
  		)

  		people = result.query(person_pattern).subjects.map do |subject| 
  			person_name_pattern = RDF::Query::Pattern.new(
  				subject,
  				Schema.name,
  				:name
  			)
  			count_pattern = RDF::Query::Pattern.new(
  				subject,
  				Parl.count,
  				:count
  			)

  			person_name = result.first_literal(person_name_pattern)
  			count = result.first_literal(count_pattern)

  			{
  				:id => self.get_id(subject),
  				:name => person_name.to_s,
  				:count => count.to_i
  			}
  		end

  		house_label_pattern = RDF::Query::Pattern.new(
  			RDF::URI.new(house_uri),
  			Rdfs.label,
  			:house_label
  		)

  		house_label = result.first_literal(house_label_pattern)

  		hierarchy = 
      		{
      			:id => self.get_id(house_uri),
      			:house_label => house_label.to_s,
      			:people => people
      		}

		{ :graph => result, :hierarchy => hierarchy }
  	end

end