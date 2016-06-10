class Vote

	include Tripod::Resource

	rdf_type 'http://data.parliament.uk/schema/parl#Vote'

	field :value, 'http://data.parliament.uk/schema/parl#value'

	linked_to :division, 'http://data.parliament.uk/schema/parl#division', class_name: 'Division'
	linked_to :member, 'http://data.parliament.uk/schema/parl#member', class_name: 'Person'

	def text
		self.value ? "Content" : "Not Content"
	end

	def self.find_by_division(division_uri)
		client = SPARQL::Client.new("http://data.ukpds.org//repositories/TempWorkerSimple2")
		division_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:division', 
		  RDF::URI.new(division_uri))
		division_title_pattern = RDF::Query::Pattern.new(
		  RDF::URI.new(division_uri), 
		  'dcterms:title', 
		  :division_title)
		value_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:value', 
		  :vote_value)
		member_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:member', 
		  :person)
		name_pattern = RDF::Query::Pattern.new(
		  :person, 
		  'schema:name', 
		  :person_name)

		query = client
		  .select
		  .prefix("parl:<http://data.parliament.uk/schema/parl#>")
		  .prefix("schema:<http://schema.org/>")
		  .prefix("dcterms:<http://purl.org/dc/terms/>")
		  .select(:division_title, :person, :person_name, :vote_value)
		  .where(division_pattern, division_title_pattern, value_pattern, member_pattern, name_pattern)

		query.result	
	end	

	def self.find_by_person(person_uri)
		client = SPARQL::Client.new("http://data.ukpds.org//repositories/TempWorkerSimple2")
		vote_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:member', 
		  RDF::URI.new(person_uri))
		person_name_pattern = RDF::Query::Pattern.new(
		  RDF::URI.new(person_uri), 
		  'schema:name', 
		  :person_name)
		vote_value_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:value', 
		  :vote_value)
		division_pattern = RDF::Query::Pattern.new(
		  :vote, 
		  'parl:division', 
		  :division)
		division_title_pattern = RDF::Query::Pattern.new(
		  :division, 
		  'dcterms:title', 
		  :division_title)

		query = client
		  .select
		  .prefix("parl:<http://data.parliament.uk/schema/parl#>")
		  .prefix("schema:<http://schema.org/>")
		  .prefix("dcterms:<http://purl.org/dc/terms/>")
		  .select(:division, :division_title, :person_name, :vote_value)
		  .where(vote_pattern, person_name_pattern, vote_value_pattern, division_pattern, division_title_pattern)

		query.result	
	end

end

