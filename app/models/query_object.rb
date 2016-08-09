class QueryObject
	include Vocabulary

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

    def self.map_linked_concepts(graph)
    	concept_pattern = RDF::Query::Pattern.new(
			:subject,
			Skos.prefLabel,
			:label)
		graph.query(concept_pattern).map do |statement|
			{
        		:id => self.get_id(statement.subject),
        		:label => statement.object.to_s
      		}
		end
    end

    def self.map_indexed_property(graph, subject)
    	indexed_pattern = RDF::Query::Pattern.new(
			subject,
			Parl.indexed,
			:indexedProperty)
		graph.first_object(indexed_pattern).to_s
    end

    def self.map_junk_property(result, subject)
    	junk_pattern = RDF::Query::Pattern.new(
			subject,
			Parl.junk,
			:junkProperty)
		result.first_object(junk_pattern).to_s
    end

    def self.sort_indexed(items)
		indexed_items = items.select { |item| item[:index_label] != "" }
		non_indexed_items = items.select { |item| item[:index_label] == "" }
		non_indexed_items + indexed_items
	end

end