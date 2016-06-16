class House

	def self.all
		client = SPARQL::Client.new(DataDriven::Application.config.database)
		result = client.query("PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
							   PREFIX schema: <http://schema.org/>
								select ?house ?name where { 
								?house rdf:type <http://data.parliament.uk/schema/parl#House>;
    	   								<http://www.w3.org/2000/01/rdf-schema#label> ?name .
								}")
		result.map do |solution| 
			Hashit.new(
			{
				:id => solution.house.to_s.split("/").last,
				:label => solution.name.to_s
			})
		end
	end

end