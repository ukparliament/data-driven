class Vote

	include Tripod::Resource

	rdf_type 'http://data.parliament.uk/schema/parl#Vote'

	field :value, 'http://data.parliament.uk/schema/parl#value'

	linked_to :division, 'http://data.parliament.uk/schema/parl#division', class_name: 'Division'

	def text
		self.value ? "Content" : "Not content"
	end

end