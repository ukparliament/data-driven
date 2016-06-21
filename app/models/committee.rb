class Committee < QueryObject
	include Vocabulary

	def self.all
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
			    ?committee schema:name ?name
			}
			WHERE { 
				?committee 
					a parl:Committee ;
			        schema:name ?name 
			} 
			")

		hierarchy = result.map do |statement|
			{
				:id => self.get_id(statement.subject),
				:name => statement.object.to_s
			}
		end
		{ :graph => result, :hierarchy => hierarchy }
	end 


end