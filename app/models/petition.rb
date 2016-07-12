class Petition < QueryObject
	include Vocabulary

	def self.all
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
	
			CONSTRUCT {
			    ?petition dcterms:title ?title .
			}
			WHERE { 
				?petition 
			        a parl:EPetition ;
			        dcterms:title ?title .
			}
			LIMIT 100
		")

		hierarchy = result.map do |statement|
			{
				:id => self.get_id(statement.subject),
				:title => statement.object.to_s
			}
		end

		{ :graph => result, :hierarchy => hierarchy }
	end

end