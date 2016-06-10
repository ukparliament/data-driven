class WrittenAnswer
	include Tripod::Resource

	rdf_type 'http://data.parliament.uk/schema/parl#WrittenParliamentaryAnswer'

	field :text, 'http://schema.org/text'
	field :date, 'http://purl.org/dc/terms/date'

	linked_to :tablingMember, 'http://data.parliament.uk/schema/parl#member', class_name: 'Person'
	linked_to :writtenQuestion, 'http://data.parliament.uk/schema/parl#question', class_name: 'WrittenQuestion'

	def id
  		self.uri.to_s.split('/').last
  	end
end