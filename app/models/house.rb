class House < QueryObject

	def self.all
		graph_data = self.client.query("PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
									CONSTRUCT {
										?house <http://www.w3.org/2000/01/rdf-schema#label> ?label .
										}
									WHERE { 
										?house rdf:type <http://data.parliament.uk/schema/parl#House>;
    	   										<http://www.w3.org/2000/01/rdf-schema#label> ?label .
									}")
		graph = RDF::Graph.new
		graph << graph_data

		hierarchy = self.convert_to_hash(graph_data)

		{:graph => graph, :hierarchy => hierarchy }
	end

	def self.find(uri)
		result = self.client.query("SELECT ?label 
									WHERE { 
										<#{uri}> <http://www.w3.org/2000/01/rdf-schema#label> ?label .
									}")
		self.convert_to_hash(result, uri).first
	end

	private

	def self.convert_to_hash(data)
		data.map do |statement| 
			{
				:id => statement.subject.to_s.split("/").last,
				:label => statement.object.to_s
			}
		end
	end

end