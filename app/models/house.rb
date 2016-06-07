class House
	include Tripod::Resource
	
	rdf_type 'http://data.parliament.uk/schema/parl#House'

	field :label, 'http://www.w3.org/2000/01/rdf-schema#label'

end