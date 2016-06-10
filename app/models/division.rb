class Division
	include Tripod::Resource

	rdf_type 'http://data.parliament.uk/schema/parl#Division'
	field :title, 'http://purl.org/dc/terms/title'
	field :description, 'http://purl.org/dc/terms/description'
	field :date, 'http://purl.org/dc/terms/date'

  linked_to :subjects, 'http://purl.org/dc/terms/subject', class_name: 'Concept', multivalued: true
  linked_to :house, 'http://data.parliament.uk/schema/parl#house', class_name: 'House'
  linked_from :votes, :division, class_name: 'Vote', multivalued: true

  def id
  	self.uri.to_s.split('/').last
  end

  def self.find_by_house(house_uri)
  	Division.find_by_sparql("
                              PREFIX parl: <http://data.parliament.uk/schema/parl#>
                              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                              select ?uri where { 
                                  ?uri rdf:type parl:Division;
                                  parl:house <#{house_uri}>            
                              }")
  end

  def self.find_by_concept(concept_uri)
    Division.find_by_sparql("
                              PREFIX parl: <http://data.parliament.uk/schema/parl#>
                              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                              PREFIX dcterms: <http://purl.org/dc/terms/>
                              select ?uri where { 
                                  ?uri rdf:type parl:Division;
                                    dcterms:subject <#{concept_uri}>
                              }")
  end

    def self.find_by_person(person_uri)
      Division.find_by_sparql("
                                PREFIX parl: <http://data.parliament.uk/schema/parl#>
                                PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                PREFIX dcterms: <http://purl.org/dc/terms/>
                                select ?uri where { 
                                    ?uri rdf:type parl:Division;
                                      parl:member <#{person_uri}>
                                }")
    end

end