class Division
	include Tripod::Resource

	rdf_type 'http://data.parliament.uk/schema/parl#Division'
	field :title, 'http://purl.org/dc/terms/title'
	field :description, 'http://purl.org/dc/terms/description'
	field :date, 'http://purl.org/dc/terms/date'

  	linked_to :subjects, 'http://purl.org/dc/terms/subject', class_name: 'Concept', multivalued: true
  	linked_to :house, 'http://data.parliament.uk/schema/parl#house', class_name: 'House'

  	def id
  		self.uri.to_s.split('/').last
  	end

end