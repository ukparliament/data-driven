class Person
	include Tripod::Resource
	
	rdf_type 'http://schema.org/Person'

	field :name, 'http://schema.org/name'
  	field :image, 'http://schema.org/image', is_uri: true

  	linked_from :writtenQuestions, :tablingMember, class_name: 'WrittenQuestion', multivalued: true
  	linked_from :oralQuestions, :tablingMember, class_name: 'OralQuestion', multivalued: true
  	linked_from :votes, :votingMember, class_name: 'Vote'

  	def id 
  		self.uri.to_s.split("/").last
  	end

  	def self.most_active_people
  		Person.find_by_sparql("PREFIX dcterms: <http://purl.org/dc/terms/>
							PREFIX parl: <http://data.parliament.uk/schema/parl#>
							SELECT ?uri
							WHERE {
							    ?question parl:member ?uri;
							}
							GROUP BY ?uri
							ORDER BY DESC(COUNT(?question))
							LIMIT 100
							")
  	end

  	def self.ordered_tabling_members_on_subject(concept_uri)
  		Person.find_by_sparql("PREFIX dcterms: <http://purl.org/dc/terms/>
							PREFIX parl: <http://data.parliament.uk/schema/parl#>
							SELECT ?uri
							WHERE {
							    ?question parl:tablingMember ?uri;
							    dcterms:subject <#{concept_uri}> .
							}
							GROUP BY ?uri
							ORDER BY DESC(COUNT(?question))
							LIMIT 100
							")
  	end

end