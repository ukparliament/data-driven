class House
	@@client = SPARQL::Client.new(DataDriven::Application.config.database)

	def self.all
		result = @@client.query("PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
								select ?house ?label where { 
								?house rdf:type <http://data.parliament.uk/schema/parl#House>;
    	   								<http://www.w3.org/2000/01/rdf-schema#label> ?label .
								}")
		self.serialize(result)
	end

	def self.find(uri)
		result = @@client.query("select ?label where { 
								<#{uri}> <http://www.w3.org/2000/01/rdf-schema#label> ?label .
								}")
		self.serialize(result, uri).first
	end

	private

	def self.serialize(data, id=nil)
		data.map do |solution| 
			id ||= solution.house
			Hashit.new(
			{
				:id => id.to_s.split("/").last,
				:label => solution.label.to_s
			})
		end
	end

end