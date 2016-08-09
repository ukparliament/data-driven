class Committee < QueryObject

	def self.all
		result = self.query('
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
			    ?committee parl:committeeName ?name ;
        				   parl:indexed ?indexedProperty ;
        				   parl:junk ?junkProperty .
			}
			WHERE {
				?committee
					a parl:Committee ;
			        schema:name ?name ;
        		OPTIONAL {
        			?committee parl:indexed ?indexedProperty .
    			}
        		OPTIONAL {
        			?committee parl:junk ?junkProperty .
    			}
			}
			')

		hierarchy = result.subjects.map do |subject|
			committee_name = self.get_object(result, subject, Parl.committeeName).to_s
			indexed_property = self.get_object(result, subject, Parl.indexed).to_s
			junk_property = self.get_object(result, subject, Parl.junk).to_s
			{
				:id => self.get_id(subject),
				:name => committee_name,
				:index_label => indexed_property,
				:junk_label => junk_property
			}
		end
		{ :graph => result, :hierarchy => hierarchy }
	end 

  def self.find(uri)
    result = self.query("
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX schema: <http://schema.org/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
	  PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
		CONSTRUCT {
        <#{uri}>
            parl:committeeName ?committeeName ;
          	parl:house ?house ;
            parl:houseLabel ?houseLabel ;
        	parl:indexed ?indexedProperty ;
            parl:junk ?junkProperty .
        ?role
            parl:membershipType ?roleType ;
            parl:member ?member ;
			a schema:Person ;
            schema:name ?memberName ;
            schema:endDate ?endDate ;
            schema:startDate ?startDate .
    	?concept
        	skos:prefLabel ?label .
      }
      WHERE {
        ?committee
              schema:name ?committeeName ;
              parl:house ?house .
          ?house
              rdfs:label ?houseLabel .
		OPTIONAL {
          	?role
				parl:committee ?committee ;
				rdf:type ?roleType ;
				parl:member ?member ;
				schema:endDate ?endDate ;
				schema:startDate ?startDate .
			?member
				schema:name ?memberName .
			}
    	    OPTIONAL {
            		?committee
                		dcterms:subject ?concept .
            		?concept
                		skos:prefLabel ?label .
        		}
        		OPTIONAL {
        			?committee
        				parl:indexed ?indexedProperty .
        		}
        		OPTIONAL {
        			?committee
        				parl:junk ?junkProperty .
        		}
    	FILTER(?committee = <#{uri}>)
      	}
      ")

		chairships = self.get_membership_by_type(result, Parl.CommitteeChair)
		memberships = self.get_membership_by_type(result, Parl.CommitteeMember)
		adviserships = self.get_membership_by_type(result, Parl.CommitteeAdviser)

		chairship_details = chairships.map do |chairship|
			self.get_committee_details(result, chairship)
		end

		membership_details = memberships.map do |membership|
			self.get_committee_details(result, membership)
		end

		advisership_details = adviserships.map do |advisership|
			self.get_committee_details(result, advisership)
		end

		id = self.get_id(uri)
		subject_uri = RDF::URI.new(uri)

		committee_name = self.get_object(result, subject_uri, Parl.committeeName).to_s
		house = self.get_object(result, subject_uri, Parl.house)
		house_id = self.get_id(house)
		house_label = self.get_object(result, subject_uri, Parl.houseLabel).to_s

		concepts = self.map_linked_concepts(result)
		indexed_property = self.get_object(result, subject_uri, Parl.indexed).to_s
		junk_property = self.get_object(result, subject_uri, Parl.junk).to_s

		hierarchy = {
				:id => id,
				:committee_name => committee_name,
				:house => {
					:id => house_id,
					:label => house_label
				},
				:chairs_count => chairships.count,
				:members_count => memberships.count,
				:advisers_count => adviserships.count,
				:memberships => membership_details,
				:chairships => chairship_details,
				:adviserships => advisership_details,
				:concepts => concepts,
				:index_label => indexed_property,
				:junk_label => junk_property
		}

		{ :graph => result, :hierarchy => hierarchy}
  end

  def self.find_by_person(person_uri)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX schema: <http://schema.org/>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			CONSTRUCT {
				?person schema:name ?personName .
				?membership
					parl:membershipType ?membershipType ;
					schema:startDate ?start ;
					schema:endDate ?end ;
					parl:committee ?committee ;
					parl:committeeName ?committeeName ;
					parl:house ?house ;
					parl:houseLabel ?houseLabel .
				?member
					a schema:Person .
			}
			WHERE {
					?person
						schema:name ?personName .
				OPTIONAL {
					?membership
							parl:member ?person ;
							a ?membershipType ;
							parl:committee ?committee ;
							schema:startDate ?start ;
							schema:endDate ?end .
					?committee
							schema:name ?committeeName ;
							parl:house ?house .
					?house
							rdfs:label ?houseLabel .

					FILTER (?membershipType = parl:CommitteeAdviser || ?membershipType = parl:CommitteeChair || ?membershipType = parl:CommitteeMember)
				}
				FILTER (?person = <#{person_uri}>)
			}
			")

		chairships = self.get_membership_by_type(result, Parl.CommitteeChair)
		memberships = self.get_membership_by_type(result, Parl.CommitteeMember)
		adviserships = self.get_membership_by_type(result, Parl.CommitteeAdviser)

		chairship_details = chairships.map do |chairship|
			self.get_committee_details_by_member(result, chairship)
		end

		membership_details = memberships.map do |membership|
			self.get_committee_details_by_member(result, membership)
		end

		advisership_details = adviserships.map do |advisership|
			self.get_committee_details_by_member(result, advisership)
		end

		person_id = self.get_id(person_uri)
		person_name = self.get_object(result, RDF::URI.new(person_uri), Schema.name).to_s

		hierarchy = {
				:person => {
						:id => person_id,
						:name => person_name
				},
				:chairs_count => chairships.count,
				:members_count => memberships.count,
				:advisers_count => adviserships.count,
				:chairships => chairship_details,
				:memberships => membership_details,
				:adviserships => advisership_details
		}

		{ :graph => result, :hierarchy => hierarchy}
	end

	def self.find_by_concept(concept_uri)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX schema: <http://schema.org/>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
			PREFIX dcterms: <http://purl.org/dc/terms/>
			CONSTRUCT {
				?concept skos:prefLabel ?label .
				?committee
					schema:name ?committeeName .
			}
			WHERE {
					?concept
						skos:prefLabel ?label .
				OPTIONAL {
					?committee
							a parl:Committee ;
            				schema:name ?committeeName;
							dcterms:subject ?concept .
    			}
				FILTER (?concept = <#{concept_uri}>)
			}
			")

		concept_id = self.get_id(concept_uri)
		label = self.get_object(result, RDF::URI.new(concept_uri), Skos.prefLabel).to_s

		committee_pattern = RDF::Query::Pattern.new(
			:subject,
			Schema.name,
			:name)
		committees = result.query(committee_pattern).map do |statement|
			{
	       		:id => self.get_id(statement.subject),
	       		:name => statement.object.to_s
	  		}
		end

		hierarchy = {
			:concept => {
					:id => concept_id,
					:label => label
			},
			:committees => committees
		}

		{ :graph => result, :hierarchy => hierarchy}
	end

	def self.get_membership_by_type(result, type)
		type_pattern = RDF::Query::Pattern.new(
				:membership,
				Parl.membershipType,
				type)
		result.query(type_pattern).subjects
	end

	def self.get_committee_details_by_member(result, membership)

		committee = self.get_object(result, membership, Parl.committee)
		committee_id = self.get_id(committee)
		committee_name = self.get_object(result, membership, Parl.committeeName).to_s
		house = self.get_object(result, membership, Parl.house)
		house_id = self.get_id(house)
		house_label = self.get_object(result, membership, Parl.houseLabel).to_s
		start_date = self.get_object(result, membership, Schema.startDate).to_s.to_datetime
		end_date = self.get_object(result, membership, Schema.endDate).to_s.to_datetime
		{
				:committee => {
						:name => committee_name,
						:id => committee_id,
				},
				:house => {
						:id => house_id,
						:label => house_label
				},
				:start_date => start_date,
				:end_date => end_date
		}
	end

	def self.get_committee_details(result, membership)

		person = self.get_object(result, membership, Parl.member)
		person_id = self.get_id(person)
		person_name = self.get_object(result, membership, Schema.name).to_s
		start_date = self.get_object(result, membership, Schema.startDate).to_s.to_datetime
		end_date = self.get_object(result, membership, Schema.endDate).to_s.to_datetime
		{
				:person => {
						:name => person_name,
						:id => person_id,
				},
				:start_date => start_date,
				:end_date => end_date
		}
	end
end