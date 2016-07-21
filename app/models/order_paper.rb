class OrderPaper < QueryObject
	include Vocabulary

	def self.all_dates
		result = self.query('
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			CONSTRUCT
			{
			    _:x parl:date ?date .
			    _:x parl:count ?count .
			}
			WHERE {
			    SELECT ?date (COUNT(?s) AS ?count)
			    WHERE 
			        {
			            ?s rdf:type parl:OrderPaperItem ;
			               dcterms:date ?date .
			        }
			    GROUP BY ?date
			    ORDER BY ?date
			}
		')
	end	

end