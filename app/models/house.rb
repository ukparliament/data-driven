class House < QueryObject

	def self.all
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX schema: <http://www.w3.org/2000/01/rdf-schema#>
			CONSTRUCT {
				?house schema:label ?label .
			}
			WHERE { 
				?house
					a parl:House ;
					schema:label ?label .
			}")

		hierarchy = self.convert_to_hash(result)

		{ :graph => result, :hierarchy => hierarchy }
	end

	def self.find(uri)
		result = self.query("
			PREFIX schema: <http://www.w3.org/2000/01/rdf-schema#>
			CONSTRUCT {
				<#{uri}> schema:label ?label .
			}
			WHERE { 
				<#{uri}> schema:label ?label .
			}")

		hierarchy = self.convert_to_hash(result).first

		{ :graph => result, :hierarchy => hierarchy }
	end

	private

	def self.convert_to_hash(data)
		data.map do |statement| 
			{
				:id => self.get_id(statement.subject),
				:label => statement.object.to_s
			}
		end
	end

end