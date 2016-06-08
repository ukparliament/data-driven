class WrittenQuestion
  	include Tripod::Resource

  	rdf_type 'http://data.parliament.uk/schema/parl#WrittenParliamentaryQuestion'

	field :text, 'http://schema.org/text'
	field :date, 'http://purl.org/dc/terms/date'

	linked_to :tablingMember, 'http://data.parliament.uk/schema/parl#member',class_name: 'Person'
  	linked_to :subjects, 'http://purl.org/dc/terms/subject', class_name: 'Concept', multivalued: true
  	linked_to :house, 'http://data.parliament.uk/schema/parl#house', class_name: 'House'

  	def id
  		self.uri.to_s.split('/').last
  	end

  	def self.find_by_house(house_uri)
	    WrittenQuestion.find_by_sparql("
	                                PREFIX parl: <http://data.parliament.uk/schema/parl#>
	                                PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
	                                select ?uri where { 
	                                    ?uri rdf:type parl:WrittenParliamentaryQuestion;
	                                      parl:house <#{house_uri}>
	                                } LIMIT 50")
	end

	def self.find_by_concept(concept_uri)
    WrittenQuestion.find_by_sparql("
	                                PREFIX parl: <http://data.parliament.uk/schema/parl#>
	                                PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
	                                PREFIX dcterms: <http://purl.org/dc/terms/>
	                                select ?uri where { 
	                                    ?uri rdf:type parl:WrittenParliamentaryQuestion;
	                                      dcterms:subject <#{concept_uri}>
	                                }")
    end
end
