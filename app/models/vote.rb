class Vote < QueryObject
	include Vocabulary

	def self.find_by_division(division_uri)
	result = self.query("
		PREFIX parl: <http://data.parliament.uk/schema/parl#>
      	PREFIX dcterms: <http://purl.org/dc/terms/>
      	PREFIX schema: <http://schema.org/>
      	CONSTRUCT {
      		<http://data.parliament.uk/resource/00089385-0000-0000-0000-000000000000>
      			dcterms:title ?title .
      		?person
      			schema:name ?name ;
      			parl:voteValue ?value .
      	}
      	WHERE {
      		?vote 
      			parl:division <http://data.parliament.uk/resource/00089385-0000-0000-0000-000000000000> ;
      			parl:value ?value ;
      			parl:member ?person .
      		<http://data.parliament.uk/resource/00089385-0000-0000-0000-000000000000>
      			dcterms:title ?title .
      		?person
      			a schema:Person ;
      			schema:name ?name .
      	}
		")

	division_title_pattern = RDF::Query::Pattern.new(
		RDF::URI.new(division_uri),
		Dcterms.title,
		:title)
	member_pattern = RDF::Query::Pattern.new(
		:person,
		Rdf.type,
		Schema.Person)

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
    	:title => title,
    	:members => members
    }

    { :graph => result, :hierarchy => hierarchy }

	end	

	def self.find_by_person(person_uri)
		client = SPARQL::Client.new(DataDriven::Application.config.database)
		vote_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:member', 
		  RDF::URI.new(person_uri))
		person_name_pattern = RDF::Query::Pattern.new(
		  RDF::URI.new(person_uri), 
		  'schema:name', 
		  :person_name)
		vote_type_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'a', 
		  RDF::URI.new('http://data.parliament.uk/schema/parl#Vote'))
		vote_value_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:value', 
		  :vote_value)
		vote_value_construct_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:voteValue', 
		  :vote_value)
		division_title_construct_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:divisionTitle', 
		  :division_title)
		division_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:division', 
		  :division)
		division_title_pattern = RDF::Query::Pattern.new(
		  :division, 
		  'dcterms:title', 
		  :division_title)

		query = client
		  .construct(person_name_pattern, vote_value_construct_pattern, division_title_construct_pattern, division_pattern)
		  .where(person_name_pattern)
		  .optional(vote_pattern, vote_type_pattern, vote_value_pattern, division_pattern, division_title_pattern)
		  .prefix("parl:<http://data.parliament.uk/schema/parl#>")
		  .prefix("schema:<http://schema.org/>")
		  .prefix("dcterms:<http://purl.org/dc/terms/>")

		query.result	
	end

end

