class OrderPaper < QueryObject
	include Vocabulary

	def self.all
		result = self.query('
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			CONSTRUCT
			{
			    _:x dcterms:date ?date .
			    _:x parl:count ?count .
			    _:x parl:indexedCount ?indexedCount .
			}
			WHERE {
			    SELECT ?date (COUNT(?s) AS ?count) (COUNT(?indexed) AS ?indexedCount)
			    WHERE 
			        {
			            ?s rdf:type parl:OrderPaperItem ;
			               dcterms:date ?date .
			            OPTIONAL
			            {
			            	?s
			            		parl:indexed ?indexed .
			            }
			        }
			    GROUP BY ?date
			    ORDER BY ?date
			}
		')

		hierarchy = result.subjects(unique: true).map do |subject|
      		id = self.get_object(result, subject, Dcterms.date).to_s
      		date = self.get_object(result, subject, Dcterms.date).to_s.to_datetime
      		items_count = self.get_object(result, subject, Parl.count).to_s
      		indexed_items_count = self.get_object(result, subject, Parl.indexedCount).to_s
      		{
      			:id => id,
      			:date => date,
      			:items_count => items_count,
      			:indexed_items_count => indexed_items_count
      		}
		end

		{ :graph => result, :hierarchy => hierarchy }
	end	

end