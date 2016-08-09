class Petition < QueryObject
	include Vocabulary

	def self.all
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
	
			CONSTRUCT {
			    ?petition 
			    	dcterms:title ?title ;
			    	parl:indexed ?indexed .
			}
			WHERE { 
				?petition 
			        a parl:EPetition ;
			        dcterms:title ?title ;
			    OPTIONAL {
			    	?petition
			    	    parl:indexed ?indexed .
			    }
			}
		")

		petitions = result.subjects.map do |subject|
			title_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Dcterms.title, 
		  		:title)
			indexed_pattern = RDF::Query::Pattern.new(
			  	subject, 
			  	Parl.indexed, 
			  	:index_label)
			title = result.first_literal(title_pattern).to_s
			index_label = result.first_literal(indexed_pattern).to_s

			{
				:id => self.get_id(subject),
				:title => title,
				:index_label => index_label
			}
		end

		hierarchy = {
			:petitions => petitions
		}

		{ :graph => result, :hierarchy => hierarchy }
	end

	def self.find(uri)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX schema: <http://schema.org/>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
	
			CONSTRUCT {
			    ?petition 
        			dcterms:title ?title ;
        			dcterms:abstract ?summary ;
        			parl:status ?status ;
        			dcterms:created ?dateCreated ;
        			dcterms:modified ?dateUpdated ;
        			dcterms:identifier ?identifier ;
        			schema:url ?externalURL ;
        			parl:indexed ?indexed .
        		?concept
        			skos:prefLabel ?label .
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
        	OPTIONAL {
        		?petition
            		dcterms:subject ?concept .
        		?concept
            		skos:prefLabel ?label .
    		}
    		OPTIONAL {
    			?petition
    				parl:indexed ?indexed .
    		}
			FILTER(?petition = <#{uri}>)
			}
			ORDER BY ASC(?constituencyLabel)
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
		indexed_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Parl.indexed, 
		  	:index_label)

		title = result.first_literal(title_pattern).to_s
		summary = result.first_literal(summary_pattern).to_s
		external_url = result.first_object(external_url_pattern).to_s
		status = result.first_literal(status_pattern).to_s
		index_label = result.first_literal(indexed_pattern).to_s
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

		concept_pattern = RDF::Query::Pattern.new(
		  	:concept, 
		  	Skos.prefLabel, 
		  	:concept_label)

		concepts = result.query(concept_pattern).subjects.map do |subject|
			concept_label_pattern = RDF::Query::Pattern.new(
		  	subject, 
		  	Skos.prefLabel, 
		  	:concept_label)
			concept_label = result.first_literal(concept_label_pattern).to_s

			{
				:id => self.get_id(subject),
				:label => concept_label
			}
		end

		hierarchy = {
			:id => self.get_id(uri),
			:title => title,
			:summary => summary,
			:status => status,
			:index_label => index_label,
			:created => date_created,
			:updated => date_modified,
			:external_url => external_url,
			:concepts => concepts,
			:constituencies => constituencies
		}

		{ :graph => result, :hierarchy => hierarchy }
	end

	def self.find_by_concept(concept_uri)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
	
			CONSTRUCT {
			    ?petition 
			    	dcterms:title ?title ;
			    	parl:indexed ?indexed .
    			?concept
        			skos:prefLabel ?label .
			}
			WHERE { 
				?petition 
			        a parl:EPetition ;
        			dcterms:subject ?concept ;
			        dcterms:title ?title .
        		?concept
                	skos:prefLabel ?label .
			    OPTIONAL {
			    	?petition
			    	    parl:indexed ?indexed .
			    }
    		FILTER (?concept = <#{concept_uri}>)
			}
		")

		label_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(concept_uri), 
		  	Skos.prefLabel, 
		  	:label)
		label = result.first_literal(label_pattern).to_s

		petition_pattern = RDF::Query::Pattern.new(
		  	:petition, 
		  	Dcterms.title, 
		  	:title)

		petitions = result.query(petition_pattern).subjects.map do |subject|
			title_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Dcterms.title, 
		  		:title)
			indexed_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Parl.indexed, 
		  		:index_label)
			title = result.first_literal(title_pattern).to_s
			index_label = result.first_literal(indexed_pattern).to_s

			{
				:id => self.get_id(subject),
				:title => title,
				:index_label => index_label
			}
		end

		hierarchy = 
			{
				:id => self.get_id(concept_uri),
				:label => label,
				:petitions => petitions
			}

		{ :graph => result, :hierarchy => hierarchy }
	end
end