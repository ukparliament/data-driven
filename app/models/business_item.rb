class BusinessItem < QueryObject
	include Vocabulary

	def self.all(date)
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

	def self.find(uri)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
			    ?item
			        dcterms:date ?date ;
			    	dcterms:title ?title ;
        			dcterms:identifier ?identifier ;
        			parl:member ?person ;
            		dcterms:abstract ?abstract ;
            		schema:previousItem ?previousItem .
			}
			WHERE { 
    			SELECT ?item ?date ?title ?identifier ?person ?abstract ?previousItem 
    			WHERE {
        				?item
			        		a parl:OrderPaperItem ;
			        		dcterms:date ?date ;
			    			dcterms:title ?title ;
        					dcterms:identifier ?identifier .

        	  	OPTIONAL {
        				?item
            				parl:member ?person ;
        		}
        		OPTIONAL {
            			?item
            				dcterms:abstract ?abstract ;
        		}
            	OPTIONAL {
            			?item
                        	schema:previousItem ?previousItem ;
        		}	
            		
         FILTER(?item = <http://id.ukpds.org/13e1ab8d-4158-4006-b9b7-b4719da8aac4>)
    }      
}")
	end
end