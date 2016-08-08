class QueryObject

	def self.query(sparql)
		RDF::Graph.new << SPARQL::Client.new(DataDriven::Application.config.database).query(sparql)
	end

	def self.get_id(uri)
		uri.to_s.split("/").last
	end

	def self.map_questions(statements)
    statements.map do |statement| 
      {
          :id => self.get_id(statement.subject),
          :text => statement.object.to_s
      }
    end
  end

end