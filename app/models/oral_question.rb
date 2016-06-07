class OralQuestion
	include Tripod::Resource

	rdf_type 'http://data.parliament.uk/schema/parl#OralParliamentaryQuestion'

	field :text, 'http://schema.org/text'
	field :date, 'http://purl.org/dc/terms/date'

	linked_to :tablingMember, 'http://data.parliament.uk/schema/parl#member',class_name: 'Person'
  linked_to :subjects, 'http://purl.org/dc/terms/subject', class_name: 'Concept', multivalued: true
  linked_to :house, 'http://data.parliament.uk/schema/parl#house', class_name: 'House'

  def id
  	self.uri.to_s.split('/').last
  end

  def plain_text
  	self.text.tr('<p>', '').tr('</p>', '')
  end
end