class Vote < QueryObject

	# include Tripod::Resource

	# rdf_type 'http://data.parliament.uk/schema/parl#Vote'

	# field :value, 'http://data.parliament.uk/schema/parl#value'

	# linked_to :division, 'http://data.parliament.uk/schema/parl#division', class_name: 'Division'
	# linked_to :member, 'http://data.parliament.uk/schema/parl#member', class_name: 'Person'

	# def text
	# 	self.value ? "Content" : "Not Content"
	# end

	def self.find_by_division(division_uri)
	result = self.query("
		PREFIX parl: <http://data.parliament.uk/schema/parl#>
      	PREFIX dcterms: <http://purl.org/dc/terms/>
      	PREFIX schema: <http://schema.org/>
      	CONSTRUCT {
      		?vote
      			parl:division <#{division_uri}> ;
      			parl:value ?value ;
      			parl:member ?person .
      		<#{division_uri}>
      			dcterms:title ?title .
      		?person
      			schema:name ?name .
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

	p title

    members = ?.map do |statement| {
    	:id => id,
    	:name => name,
    	:vote_value => vote_value
    	}
	end

    hierarchy = {
    	:id => id,
    	:title => title,
    	:members => members
    }

    { :graph => result, :hierarchy => hierarchy }
		# division_pattern = RDF::Query::Pattern.new(
		#   :vote, 
		#   'parl:division', 
		#   RDF::URI.new(division_uri))
		# division_title_pattern = RDF::Query::Pattern.new(
		#   RDF::URI.new(division_uri), 
		#   'dcterms:title', 
		#   :division_title)
		# value_pattern = RDF::Query::Pattern.new(
		#   :vote, 
		#   'parl:value', 
		#   :vote_value)
		# member_pattern = RDF::Query::Pattern.new(
		#   :vote, 
		#   'parl:member', 
		#   :person)
		# name_pattern = RDF::Query::Pattern.new(
		#   :person, 
		#   'schema:name', 
		#   :person_name)

		# query = client
		#   .select
		#   .prefix("parl:<http://data.parliament.uk/schema/parl#>")
		#   .prefix("schema:<http://schema.org/>")
		#   .prefix("dcterms:<http://purl.org/dc/terms/>")
		#   .select(:division_title, :person, :person_name, :vote_value)
		#   .where(division_pattern, division_title_pattern, value_pattern, member_pattern, name_pattern)

		# query.result	
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

