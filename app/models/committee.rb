class Committee < QueryObject
	include Vocabulary

	def self.all
		result = self.query('
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
			    ?committee schema:name ?name
			}
			WHERE {
				?committee
					a parl:Committee ;
			        schema:name ?name
			}
			')

		hierarchy = result.map do |statement|
			{
				:id => self.get_id(statement.subject),
				:name => statement.object.to_s
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
      CONSTRUCT {
          <#{uri}>
              parl:committeeName ?committeeName ;
          		parl:house ?house ;
              parl:houseLabel ?houseLabel .
          ?role
              rdf:type ?roleType ;
              parl:member ?member ;
              schema:name ?memberName ;
              schema:endDate ?endDate ;
              schema:startDate ?startDate .
      }
      WHERE {
        <#{uri}>
              schema:name ?name ;
              parl:house ?house .
          ?house
              rdfs:label ?houseLabel .
          ?role
              parl:committee <#{uri}> ;
              rdf:type ?roleType ;
              parl:member ?member ;
              schema:endDate ?endDate ;
              schema:startDate ?startDate .
          ?member
              schema:name ?memberName .
      }
      ")

		members = result.subjects
										.select{ |subject| subject != RDF::URI.new(uri)}
										.map do |subject|
			person_pattern = RDF::Query::Pattern.new(
					subject,
					Parl.member,
					:person)
			person_name_pattern = RDF::Query::Pattern.new(
					subject,
					Schema.name,
					:person_name)
			role_pattern = RDF::Query::Pattern.new(
					subject,
					Rdf.type,
					:role)
			start_date_pattern = RDF::Query::Pattern.new(
					subject,
					Schema.startDate,
					:start_date)
			end_date_pattern = RDF::Query::Pattern.new(
					subject,
					Schema.endDate,
					:end_date)

			person = result.first_object(person_pattern)
			person_id = self.get_id(person)
			person_name = result.first_literal(person_name_pattern)
			role = result.first_object(role_pattern).to_s
			start_date = result.first_object(start_date_pattern).to_s.to_datetime
			end_date = result.first_object(end_date_pattern).to_s.to_datetime

			{
					:id => person_id,
					:name => person_name,
					:role => role,
					:start_date => start_date,
					:end_date => end_date
			}
		end

		id = self.get_id(uri)
		committee_name_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(uri),
				Parl.committeeName,
				:committee_name)
		house_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(uri),
				Parl.house,
				:house)
		house_label_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(uri),
				Parl.houseLabel,
				:house_label)

		committee_name = result.first_literal(committee_name_pattern)
		house = result.first_object(house_pattern)
		house_id = self.get_id(house)
		house_label = result.first_literal(house_label_pattern).to_s

		hierarchy = {
				:id => id,
				:committee_name => committee_name,
				:house => {
						:id => house_id,
						:label => house_label
				},
				:members => members
		}

		{ :graph => result, :hierarchy => hierarchy}
  end

  def self.find_by_person(person_uri)
		result = self.query("
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX schema: <http://schema.org/>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			CONSTRUCT {
				?person parl:personName ?personName .
				?membership
					parl:membershipType ?membershipType ;
					schema:startDate ?start ;
					schema:endDate ?end ;
					parl:committee ?committee ;
					parl:committeeName ?committeeName ;
					parl:house ?house ;
					parl:houseLabel ?houseLabel .
			}
			WHERE {
					?person
							schema:name ?personName .
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
					FILTER (?person = <#{person_uri}>)
			}
			")

		chairships = self.get_membership_by_type(result, Parl.CommitteeChair)
		memberships = self.get_membership_by_type(result, Parl.CommitteeMember)
		adviserships = self.get_membership_by_type(result, Parl.CommitteeAdviser)

		chairship_details = chairships.map do |chairship|
			self.get_details(result, chairship)
		end

		membership_details = memberships.map do |membership|
			self.get_details(result, membership)
		end

		advisership_details = adviserships.map do |advisership|
			self.get_details(result, advisership)
		end

		person_name_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(person_uri),
				Parl.personName,
				:person_name)

		person_id = self.get_id(person_uri)
		person_name = result.first_literal(person_name_pattern)

		hierarchy = {
				:person => {
						:id => person_id,
						:name => person_name
				},
				:chairs => chairships.count,
				:members => memberships.count,
				:advisers => adviserships.count,
				:chairships => chairship_details,
				:memberships => membership_details,
				:adviserships => advisership_details
		}

		{ :graph => result, :hierarchy => hierarchy}
	end

	def self.get_membership_by_type(result, type)
		p type
		type_pattern = RDF::Query::Pattern.new(
				:membership,
				Parl.membershipType,
				type)
		result.query(type_pattern).subjects
	end

	def self.get_details(result, membership)
		committee_pattern = RDF::Query::Pattern.new(
				membership,
				Parl.committee,
				:committee)
		committee_name_pattern = RDF::Query::Pattern.new(
				membership,
				Parl.committeeName,
				:committee_name)
		start_date_pattern = RDF::Query::Pattern.new(
				membership,
				Schema.startDate,
				:start_date)
		end_date_pattern = RDF::Query::Pattern.new(
				membership,
				Schema.endDate,
				:end_date)
		house_pattern = RDF::Query::Pattern.new(
				membership,
				Parl.house,
				:house)
		house_label_pattern = RDF::Query::Pattern.new(
				membership,
				Parl.houseLabel,
				:house_label)

		committee = result.first_object(committee_pattern)
		committee_id = self.get_id(committee)
		committee_name = result.first_literal(committee_name_pattern)
		house = result.first_object(house_pattern)
		house_id = self.get_id(house)
		house_label = result.first_literal(house_label_pattern)
		start_date = result.first_object(start_date_pattern).to_s.to_datetime
		end_date = result.first_object(end_date_pattern).to_s.to_datetime
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
end