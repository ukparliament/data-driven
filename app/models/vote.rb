class Vote

	include Tripod::Resource

	rdf_type 'http://data.parliament.uk/schema/parl#Vote'

	field :value, 'http://data.parliament.uk/schema/parl#value'

	linked_to :division, 'http://data.parliament.uk/schema/parl#division', class_name: 'Division'
	linked_to :member, 'http://data.parliament.uk/schema/parl#member', class_name: 'Person'

	def text
		self.value ? "Content" : "Not Content"
	end

	def self.find_by_division(division_uri)
		Vote.find_by_sparql("PREFIX parl: <http://data.parliament.uk/schema/parl#>
							 select ?uri where { ?uri parl:division <#{division_uri}> . } limit 10")
	end

end
