class BusinessItem < QueryObject
	include Vocabulary

	#rename this method
	def self.find_by_date(date)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			CONSTRUCT {
			    ?orderPaperItem
			        dcterms:title ?title .
			}
			WHERE { 
				?orderPaperItem 
			        a parl:OrderPaperItem ;
			        dcterms:date \"#{date}\"^^xsd:date ;
			    	dcterms:title ?title .               
			}
		")


		order_paper_items = result.map do |statement|
			{
				:id => self.get_id(statement.subject),
				:title => statement.object.to_s
			}
		end

		hierarchy = {
			:date => date.to_datetime,
			:order_paper_items => order_paper_items
		}

		{ :graph => result, :hierarchy => hierarchy }
	end
end