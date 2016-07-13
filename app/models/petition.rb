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
		")

		hierarchy = result.map do |statement|
			{
				:id => self.get_id(statement.subject),
				:title => statement.object.to_s
			}
		end

		{ :graph => result, :hierarchy => hierarchy }
	end

	def self.find(uri)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX schema: <http://schema.org/>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	
			CONSTRUCT {
			    ?petition 
        			dcterms:title ?title ;
        			dcterms:abstract ?summary ;
        			parl:status ?status ;
        			dcterms:created ?dateCreated ;
        			dcterms:modified ?dateUpdated ;
        			dcterms:identifier ?identifier ;
        			schema:url ?externalURL .
        		?constituency
            		rdfs:label ?constituencyLabel ;
            		parl:numberOfSignatures ?numberOfSignatures .
			}
			WHERE { 
				?petition 
			        a parl:EPetition ;
			        dcterms:title ?title ;
        			dcterms:abstract ?summary ;
        			parl:status ?status ;
        			dcterms:created ?dateCreated ;
        			dcterms:modified ?dateUpdated ;
        			dcterms:identifier ?identifier ;
        			schema:url ?externalURL .
        		?signatures
                	parl:ePetition ?petition ;
        			parl:numberOfSignatures ?numberOfSignatures ;
        			parl:constituency ?constituency .
    			?constituency
        			a parl:Constituency ;
        			rdfs:label ?constituencyLabel .
        
			FILTER(?petition = <#{uri}>)
			}
		")

		title_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Dcterms.title, 
		  	:title)
		summary_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Dcterms.abstract, 
		  	:abstract)
		external_url_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Schema.url, 
		  	:url)
		status_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Parl.status, 
		  	:status)
		date_created_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Dcterms.created, 
		  	:created_date)
		date_modified_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Dcterms.modified, 
		  	:modified_date)
		constituency_pattern = RDF::Query::Pattern.new(
		  	:constituency, 
		  	Rdfs.label, 
		  	:constituency_label)

		title = result.first_literal(title_pattern).to_s
		summary = result.first_literal(summary_pattern).to_s
		external_url = result.first_object(external_url_pattern).to_s
		status = result.first_literal(status_pattern).to_s
		date_created = result.first_object(date_created_pattern).to_s.to_datetime.strftime("%d %B %Y")
		date_modified = result.first_object(date_modified_pattern).to_s.to_datetime.strftime("%d %B %Y")

		constituencies = result.query(constituency_pattern).subjects.map do |subject|
			constituency_label_pattern = RDF::Query::Pattern.new(
		  	subject, 
		  	Rdfs.label, 
		  	:constituency_label)
			number_of_signatures_pattern = RDF::Query::Pattern.new(
		  	subject, 
		  	Parl.numberOfSignatures, 
		  	:number_of_signatures)

			constituency_label = result.first_literal(constituency_label_pattern).to_s
			number_of_signatures = result.first_literal(number_of_signatures_pattern).to_i

			{
				:id => self.get_id(subject),
				:constituency_label => constituency_label,
				:number_of_signatures => number_of_signatures
			}
		end

		hierarchy = {
			:id => self.get_id(uri),
			:title => title,
			:summary => summary,
			:status => status,
			:created => date_created,
			:updated => date_modified,
			:external_url => external_url,
			:constituencies => constituencies
		}

		{ :graph => result, :hierarchy => hierarchy }
	end

end