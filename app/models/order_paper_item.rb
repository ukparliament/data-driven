class OrderPaperItem < QueryObject
	include Vocabulary

	def self.all
		result = self.query('
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
			    ?orderPaperItem
			        dcterms:title ?title ;
    				schema:previousItem ?previousItem ;
    				parl:indexed ?indexedProperty ;
    				parl:junk ?junkProperty .
			}
			WHERE { 
    			SELECT ?orderPaperItem ?title ?previousItem ?indexedProperty ?junkProperty
    			WHERE {
        			?orderPaperItem 
			        	a parl:OrderPaperItem ;
			        	dcterms:date ?date ;
			    		dcterms:title ?title . 
        			OPTIONAL {
    					?orderPaperItem 
    						schema:previousItem ?previousItem .
    				}
    				OPTIONAL {
    					?orderPaperItem
    						parl:indexed ?indexedProperty .
    				}
    				OPTIONAL {
    					?orderPaperItem
    						parl:junk ?junkProperty .
    				}
				}
			}')

		order_paper_items = OrderPaperItem.order_paper_items_mapper(result, result.subjects)

		hierarchy = {
			:order_paper_items => order_paper_items
		}

		{ :graph => result, :hierarchy => hierarchy }
	end

	def self.all_by_date(date)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
			    ?orderPaperItem
			        dcterms:title ?title ;
    				schema:previousItem ?previousItem ;
    				parl:indexed ?indexedProperty ;
    				parl:junk ?junkProperty .
			}
			WHERE { 
    			SELECT ?orderPaperItem ?title ?previousItem ?indexedProperty ?junkProperty
    			WHERE {
        			?orderPaperItem 
			        	a parl:OrderPaperItem ;
			        	dcterms:date \"#{date}\"^^xsd:date ;
			    		dcterms:title ?title . 
        			OPTIONAL {
    					?orderPaperItem 
    						schema:previousItem ?previousItem .
    				}
    				OPTIONAL {
    					?orderPaperItem
    						parl:indexed ?indexedProperty .
    				}
    				OPTIONAL {
    					?orderPaperItem
    						parl:junk ?junkProperty .
    				}
				}
			}
		")

		order_paper_items = OrderPaperItem.order_paper_items_mapper(result, result.subjects)

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
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
			CONSTRUCT {
			    ?item
			        dcterms:date ?date ;
			    	dcterms:title ?title ;
        			dcterms:identifier ?identifier ;
            		dcterms:abstract ?abstract ;
            		schema:previousItem ?previousItem ;
            		parl:indexed ?indexedProperty ;
            		parl:junk ?junkProperty ;
            		parl:businessItemType ?businessItemType ;
            		parl:memberRole ?memberRole .
    			?concept
        			skos:prefLabel ?label .
            	?person
            		schema:name ?person_name .
			}
			WHERE { 
    			SELECT ?item ?date ?title ?identifier ?person ?abstract ?previousItem ?person_name ?concept ?label ?indexedProperty ?junkProperty ?businessItemType ?memberRole
    			WHERE {
        			?item
			        	a parl:OrderPaperItem ;
			        	dcterms:date ?date ;
			    		dcterms:title ?title ;
        				dcterms:identifier ?identifier .

        	  	OPTIONAL {
        			?item
            			parl:member ?person .
            		?person
                        schema:name ?person_name .
        		}
        		OPTIONAL {
            		?item
            			dcterms:abstract ?abstract .
        		}
            	OPTIONAL {
            		?item
                       	schema:previousItem ?previousItem .
        		}
        		OPTIONAL {
            		?item
                		dcterms:subject ?concept .
            		?concept
                		skos:prefLabel ?label .
        		}
        		OPTIONAL {
        			?item
        				parl:indexed ?indexedProperty .
        		}
        		OPTIONAL {
        			?item
        				parl:junk ?junkProperty .
        		}
        		OPTIONAL {
        			?item
        				parl:businessItemType ?businessItemType .
        		}
        		OPTIONAL {
        			?item
        				parl:memberRole ?memberRole .
        		}
         		FILTER(?item = <#{uri}>)
    		}      
		}"
		)

		date_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Dcterms.date, 
		  	:date)
		date = result.first_object(date_pattern).to_s.to_datetime
		title_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Dcterms.title, 
		  	:title)
		title = result.first_literal(title_pattern).to_s
		person_pattern = RDF::Query::Pattern.new(
		  	:person, 
		  	Schema.name, 
		  	:name)
		person = result.first_subject(person_pattern)
		person_name = result.first_literal(person_pattern).to_s
		abstract_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Dcterms.abstract, 
		  	:abstract)
		abstract = result.first_literal(abstract_pattern).to_s
		previous_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(uri), 
		  	Schema.previousItem, 
		  	:previousItem)
		previousItemURI = result.first_object(previous_pattern)
		indexed_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.indexed,
			:indexedProperty)
		indexed_property = result.first_object(indexed_pattern).to_s
		junk_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.junk,
			:junkProperty)
		junk_property = result.first_object(junk_pattern).to_s
		business_item_type_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.businessItemType,
			:businessItemType)
		business_item_type_property = result.first_object(business_item_type_pattern).to_s
		member_role_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.memberRole,
			:memberRole)
		member_role = result.first_object(member_role_pattern).to_s

		concept_pattern = RDF::Query::Pattern.new(
			:subject,
			Skos.prefLabel,
			:label)
		concepts = result.query(concept_pattern).map do |statement|
			{
        		:id => self.get_id(statement.subject),
        		:label => statement.object.to_s
      		}
		end

		hierarchy = 
			{
				:id => self.get_id(uri),
				:date => date,
				:title => title,
				:person => {
					:id => self.get_id(person),
					:name => person_name,
					:role => member_role
					},
				:abstract => abstract,
				:previousItemId => self.get_id(previousItemURI),
				:index_label => indexed_property,
				:junk_label => junk_property,
				:business_item_type => business_item_type_property,
				:concepts => concepts
			}

		{ :graph => result, :hierarchy => hierarchy }
	end

	def self.find_by_concept(concept_uri)
		result = self.query("
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			CONSTRUCT {
				?concept
					skos:prefLabel ?label .
			    ?item
			        dcterms:date ?date ;
			    	dcterms:title ?title ;
			    	parl:indexed ?indexedProperty ;
			    	parl:junk ?junkProperty .
			}
			WHERE { 
				?concept
			    	skos:prefLabel ?label .
			    OPTIONAL {
			    	?item
			       		a parl:OrderPaperItem ;
        				dcterms:subject ?concept ;
			       		dcterms:date ?date ;
			    		dcterms:title ?title .
			    }
			    OPTIONAL {
    				?item
    					parl:indexed ?indexedProperty .
    			}
    			OPTIONAL {
    				?item
    					parl:junk ?junkProperty .
    			}
         		FILTER(?concept = <#{concept_uri}>)
			}
		")

		order_paper_items_pattern = RDF::Query::Pattern.new(
		  	:item, 
		  	Dcterms.date, 
		  	:date)

		order_paper_items = OrderPaperItem.order_paper_items_mapper(result, result.query(order_paper_items_pattern).subjects)

		label_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(concept_uri), 
		  	Skos.prefLabel, 
		  	:label)
		label = result.first_literal(label_pattern).to_s

		hierarchy = {
			:id => self.get_id(concept_uri),
			:label => label,
			:order_paper_items => order_paper_items
		}

		{ :graph => result, :hierarchy => hierarchy }
	end

	def self.find_by_person(person_uri)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
				?person
					schema:name ?name .
			    ?item
			        dcterms:date ?date ;
			    	dcterms:title ?title ;
			    	parl:indexed ?indexedProperty ;
			    	parl:junk ?junkProperty .
			}
			WHERE { 
				?person
			    	schema:name ?name .

			    OPTIONAL {
					?item
			    	   	a parl:OrderPaperItem ;
        				parl:member ?person ;
			    	   	dcterms:date ?date ;
			    		dcterms:title ?title .
			    }
			    OPTIONAL {
    				?item
    					parl:indexed ?indexedProperty .
    			}
    			OPTIONAL {
    				?item
    					parl:junk ?junkProperty .
    			}
         		FILTER(?person = <#{person_uri}>)
			}
		")

		name_pattern = RDF::Query::Pattern.new(
		  	RDF::URI.new(person_uri), 
		  	Schema.name, 
		  	:name)
		name = result.first_literal(name_pattern).to_s

		order_paper_items_pattern = RDF::Query::Pattern.new(
		  	:item, 
		  	Dcterms.date, 
		  	:date)

		order_paper_items = OrderPaperItem.order_paper_items_mapper(result, result.query(order_paper_items_pattern).subjects)

		hierarchy = {
			:id => self.get_id(person_uri),
			:name => name,
			:order_paper_items => order_paper_items
		}

		{ :graph => result, :hierarchy => hierarchy }

	end


	private

	def self.order_paper_items_mapper(result, subjects)
		subjects.map do |subject|
			title_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Dcterms.title, 
		  		:title)
			title = result.first_literal(title_pattern).to_s
			previous_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Schema.previousItem, 
		  		:previousItem)
			previousItemURI = result.first_object(previous_pattern)
			indexed_pattern = RDF::Query::Pattern.new(
				subject,
				Parl.indexed,
				:indexedProperty)
			indexed_property = result.first_object(indexed_pattern).to_s
			junk_pattern = RDF::Query::Pattern.new(
				subject,
				Parl.junk,
				:junkProperty)
			junk_property = result.first_object(junk_pattern).to_s
			{
				:id => self.get_id(subject),
				:title => title,
				:index_label => indexed_property,
				:junk_label => junk_property,
				:previousItemId => self.get_id(previousItemURI)
			}
		end
	end

end