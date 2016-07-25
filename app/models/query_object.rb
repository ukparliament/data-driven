class QueryObject

	def self.query(sparql)
		RDF::Graph.new << SPARQL::Client.new(DataDriven::Application.config.database).query(sparql)
	end

	def self.get_id(uri)
		uri.to_s.split("/").last
	end

	def self.insert(sparql)
		RDF::Graph.load(DataDriven::Application.config.database+'/statements').insert(sparql)
	end

end