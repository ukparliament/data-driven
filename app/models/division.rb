class Division < QueryObject
	# include Tripod::Resource

	# rdf_type 'http://data.parliament.uk/schema/parl#Division'
	# field :title, 'http://purl.org/dc/terms/title'
	# field :description, 'http://purl.org/dc/terms/description'
	# field :date, 'http://purl.org/dc/terms/date'

 #  linked_to :subjects, 'http://purl.org/dc/terms/subject', class_name: 'Concept', multivalued: true
 #  linked_to :house, 'http://data.parliament.uk/schema/parl#house', class_name: 'House'
 #  linked_from :votes, :division, class_name: 'Vote', multivalued: true

 #  def id
 #  	self.uri.to_s.split('/').last
 #  end

 def self.all
      result = self.query("
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      CONSTRUCT {
        ?division dcterms:title ?title .
      }
      WHERE { 
        ?division
          a parl:Division ;
          dcterms:title ?title .
      }")

    hierarchy = result.map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :title => statement.object.to_s
      }
    end

    { :graph => result, :hierarchy => hierarchy }
 end

  # def self.find_by_house(house_uri)
  # 	Division.find_by_sparql("
  #                             PREFIX parl: <http://data.parliament.uk/schema/parl#>
  #                             PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  #                             select ?uri where { 
  #                                 ?uri rdf:type parl:Division;
  #                                 parl:house <#{house_uri}>            
  #                             }")
  # end

  # def self.find_by_concept(concept_uri)
  #   Division.find_by_sparql("
  #                             PREFIX parl: <http://data.parliament.uk/schema/parl#>
  #                             PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  #                             PREFIX dcterms: <http://purl.org/dc/terms/>
  #                             select ?uri where { 
  #                                 ?uri rdf:type parl:Division;
  #                                   dcterms:subject <#{concept_uri}>
  #                             }")
  # end

  #   def self.find_by_person(person_uri)
  #     Division.find_by_sparql("
  #                               PREFIX parl: <http://data.parliament.uk/schema/parl#>
  #                               PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  #                               PREFIX dcterms: <http://purl.org/dc/terms/>
  #                               select ?uri where { 
  #                                   ?uri rdf:type parl:Division;
  #                                     parl:member <#{person_uri}>
  #                               }")
  #   end

end