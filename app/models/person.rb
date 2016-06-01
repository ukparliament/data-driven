class Person
	include Tripod::Resource
	
	rdf_type 'http://schema.org/Person'

	field :name, 'http://schema.org/name'
  	field :image, 'http://schema.org/image', is_uri: true

  	linked_from :writtenQuestions, :tablingMember, class_name: 'WrittenQuestion', multivalued: true

  	def id 
  		self.uri.to_s.split("/").last
  	end
end