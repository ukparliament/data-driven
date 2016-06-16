class Concept
	@@client = SPARQL::Client.new(DataDriven::Application.config.database)

  # include Tripod::Resource

  # rdf_type 'http://www.w3.org/2004/02/skos/core#Concept'

  # field :label, 'http://www.w3.org/2004/02/skos/core#prefLabel'
  # linked_from :writtenQuestions, :subjects, class_name: 'WrittenQuestion', multivalued: true

  # def id 
  # 	self.uri.to_s.split("/").last
  # end

	def self.most_popular_by_contribution
	  	result = @@client.query("PREFIX dcterms: <http://purl.org/dc/terms/>
							SELECT ?concept ?label
							WHERE {
							    ?contribution dcterms:subject ?concept .
	    						?concept <http://www.w3.org/2004/02/skos/core#prefLabel> ?label .
	        
							}
							GROUP BY ?concept ?label
							ORDER BY DESC(COUNT(?contribution))
							LIMIT 50
							")
	  	self.serialize(result)
	end

  # def self.most_popular_by_question_for_tabling_member(person_uri)
  # 	Concept.find_by_sparql("PREFIX dcterms: <http://purl.org/dc/terms/>
		# 				PREFIX parl: <http://data.parliament.uk/schema/parl#>
		# 				SELECT ?uri
		# 				WHERE {
		# 				    ?question dcterms:subject ?uri;
		# 				    parl:tablingMember <#{person_uri}> .
		# 				}
		# 				GROUP BY ?uri
		# 				ORDER BY DESC(COUNT(?question))
		# 				LIMIT 100
		# 				")
  # end

	def self.find(uri)
		result = @@client.query("select ?label where { 
								<#{uri}> <http://www.w3.org/2004/02/skos/core#prefLabel> ?label .
								}")
		self.serialize(result, uri).first
	end

	private

	def self.serialize(data, id=nil)
		data.map do |solution| 
			id ||= solution.concept
			Hashit.new(
			{
				:id => id.to_s.split("/").last,
				:label => solution.label.to_s
			})
		end
	end
end