class Vote
	include Tripod::Resource

	rdf_type 'http://data.parliament.uk/schema/parl#Vote'

	field :value, 'http://data.parliament.uk/schema/parl#value'

	
end