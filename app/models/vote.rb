class Vote < QueryObject
	include Vocabulary

	def self.find_by_division(division_uri)
	result = self.query("
		PREFIX parl: <http://data.parliament.uk/schema/parl#>
    PREFIX dcterms: <http://purl.org/dc/terms/>
    PREFIX schema: <http://schema.org/>
    CONSTRUCT {
    	?division
    		dcterms:title ?title .
    	?person
    		schema:name ?name ;
    		parl:voteValue ?value .
    }
    WHERE {
    	?vote 
    		parl:division ?division ;
    		parl:value ?value ;
    		parl:member ?person .
    	?division
    		dcterms:title ?title .
    	?person
    		schema:name ?name .
      FILTER(?division = <#{division_uri}>)
    }
	")

	title = self.get_object(result, RDF::URI.new(division_uri), Dcterms.title).to_s

  members_pattern = RDF::Query::Pattern.new(
    :person,
    Schema.name,
    :name)

  members = result.query(members_pattern).subjects.map do |subject|
    name = self.get_object(result, subject, Schema.name).to_s
		vote_value = self.get_object(result, subject, Parl.voteValue).to_s

		{
    	:id => self.get_id(subject),
    	:name => name,
    	:vote_value => vote_value
    }
	end

    hierarchy = {
    	:id => self.get_id(division_uri),
    	:title => title,
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
        ?person schema:name ?name
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
  
	  name = self.get_object(result, RDF::URI.new(person_uri), Schema.name).to_s
    division_pattern = RDF::Query::Pattern.new(
      :division,
      Dcterms.title,
      :title)
    divisions = result.query(division_pattern).subjects.map do |subject|
	 	  title = self.get_object(result, subject, Dcterms.title).to_s
	 	  vote_value = self.get_object(result, subject, Parl.voteValue).to_s
  
	 		{
      	:id => self.get_id(subject),
      	:title => title,
      	:vote_value => vote_value
      }
	  end

    hierarchy = {
    	:id => self.get_id(person_uri),
    	:name => name,
    	:divisions => divisions
    }

    { :graph => result, :hierarchy => hierarchy }

	end

end

