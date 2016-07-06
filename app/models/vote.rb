class Vote < QueryObject
	include Vocabulary

	def self.find_by_division(division_uri)
	result = self.query("
		PREFIX parl: <http://data.parliament.uk/schema/parl#>
      	PREFIX dcterms: <http://purl.org/dc/terms/>
      	PREFIX schema: <http://schema.org/>
      	CONSTRUCT {
      		<#{division_uri}>
      			dcterms:title ?title .
      		?person
            a schema:Person ;
      			schema:name ?name ;
      			parl:voteValue ?value .
      	}
      	WHERE {
      		?vote 
      			parl:division <#{division_uri}> ;
      			parl:value ?value ;
      			parl:member ?person .
      		<#{division_uri}>
      			dcterms:title ?title .
      		?person
      			schema:name ?name .
      	}
		")

	division_title_pattern = RDF::Query::Pattern.new(
		RDF::URI.new(division_uri),
		Dcterms.title,
		:title)

	id = self.get_id(division_uri)
	title = result.first_literal(division_title_pattern)

    members = result.subjects
    	.select{ |subject| subject != RDF::URI.new(division_uri) }
    	.map do |subject|
    		name_pattern = RDF::Query::Pattern.new(
			subject,
			Schema.name,
			:name)
    		vote_value_pattern = RDF::Query::Pattern.new(
			subject,
			Parl.voteValue,
			:voteValue)
	
			name = result.first_literal(name_pattern)
			vote_value = result.first_object(vote_value_pattern)

			{
    			:id => self.get_id(subject),
    			:name => name.to_s,
    			:vote_value => vote_value.to_s
    		}
		end

    hierarchy = {
    	:id => id,
    	:title => title.to_s,
    	:members => members
    }

    { :graph => result, :hierarchy => hierarchy }

	end	

	def self.find_by_person(person_uri)
	result = self.query("
		PREFIX parl: <http://data.parliament.uk/schema/parl#>
      	PREFIX dcterms: <http://purl.org/dc/terms/>
      	PREFIX schema: <http://schema.org/>
      	CONSTRUCT {
      		?person
            a schema:Person ;
      			schema:name ?name .
      		?division
      			dcterms:title ?title ;
      			parl:voteValue ?value .
      	}
      	WHERE {
          ?person schema:name ?name .

          OPTIONAL {
            ?vote 
              parl:member ?person ;
              parl:value ?value ;
              parl:division ?division .
            ?division
              dcterms:title ?title .
          }
          FILTER(?person = <#{person_uri}>)
      	}
		")

	member_name_pattern = RDF::Query::Pattern.new(
		RDF::URI.new(person_uri),
		Schema.name,
		:name)

	id = self.get_id(person_uri)
	name = result.first_literal(member_name_pattern)

    divisions = result.subjects
    	.select{ |subject| subject != RDF::URI.new(person_uri) }
    	.map do |subject|
    		title_pattern = RDF::Query::Pattern.new(
			subject,
			Dcterms.title,
			:title)
    		vote_value_pattern = RDF::Query::Pattern.new(
			subject,
			Parl.voteValue,
			:voteValue)
	
			title = result.first_literal(title_pattern)
			vote_value = result.first_object(vote_value_pattern)
			p vote_value
			{
    			:id => self.get_id(subject),
    			:title => title.to_s,
    			:vote_value => vote_value.to_s
    		}
		end

    hierarchy = {
    	:id => id,
    	:name => name.to_s,
    	:divisions => divisions
    }

    { :graph => result, :hierarchy => hierarchy }

	end

end

