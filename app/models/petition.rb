class Petition < QueryObject

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
			title = self.get_object(result, subject, Dcterms.title).to_s
			index_label = self.get_object(result, subject, Parl.indexed).to_s

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

		petition_uri = RDF::URI.new(uri)
		title = self.get_object(result, petition_uri, Dcterms.title).to_s
		summary = self.get_object(result, petition_uri, Dcterms.abstract).to_s
		external_url = self.get_object(result, petition_uri, Schema.url).to_s
		status = self.get_object(result, petition_uri, Parl.status).to_s
		index_label = self.get_object(result, petition_uri, Parl.indexed).to_s
		date_created = self.get_object(result, petition_uri, Dcterms.created).to_s.to_datetime.strftime("%d %B %Y")
		date_modified = self.get_object(result, petition_uri, Dcterms.modified).to_s.to_datetime.strftime("%d %B %Y")

		constituency_pattern = RDF::Query::Pattern.new(
		  	:constituency, 
		  	Rdfs.label, 
		  	:constituency_label)

		constituencies = result.query(constituency_pattern).subjects.map do |subject|
			constituency_label = self.get_object(result, subject, Rdfs.label).to_s
			number_of_signatures = self.get_object(result, subject, Parl.numberOfSignatures).to_i

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
			concept_label = self.get_object(result, subject, Skos.prefLabel).to_s

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
				?concept
                	skos:prefLabel ?label .
                OPTIONAL {
                	?petition 
			        	a parl:EPetition ;
        				dcterms:subject ?concept ;
			        	dcterms:title ?title .
                }
			    OPTIONAL {
			    	?petition
			    	    parl:indexed ?indexed .
			    }
    		FILTER (?concept = <#{concept_uri}>)
			}
		")

		label = self.get_object(result, RDF::URI.new(concept_uri), Skos.prefLabel).to_s

		petition_pattern = RDF::Query::Pattern.new(
		  	:petition, 
		  	Dcterms.title, 
		  	:title)

		petitions = result.query(petition_pattern).subjects.map do |subject|
			title = self.get_object(result, subject, Dcterms.title).to_s
			index_label = self.get_object(result, subject, Parl.indexed).to_s

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