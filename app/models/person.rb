class Person < QueryObject
	include Vocabulary 

  	def self.most_active_people
  			result = self.query('
					PREFIX parl: <http://data.parliament.uk/schema/parl#>
					PREFIX schema: <http://schema.org/>
					CONSTRUCT {
						?person
							a schema:Person ;
							schema:name ?name ;
							parl:count ?count .
					}
					WHERE {
						SELECT ?person ?name (COUNT(?contribution) AS ?count)
						WHERE {
							?person
								a schema:Person ;
								schema:name ?name .
							?contribution parl:member ?person .
						}
						GROUP BY ?person ?name
						ORDER BY DESC(?count)
						LIMIT 100
					}
				')

		people = result.subjects(unique: true).map do |subject| 
			name_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Schema.name, 
		  		:name)
			name = result.first_literal(name_pattern)
			count_pattern = RDF::Query::Pattern.new(
		  		subject, 
		  		Parl.count, 
		  		:count)
			count = result.first_literal(count_pattern)

			{
				:id => self.get_id(subject),
				:name => name.to_s,
				:count => count.to_i
			}
		end

		hierarchy = {
			:people => people
		}

		{ :graph => result, :hierarchy => hierarchy }

  	end

  	def self.find(uri)
  		result = self.query("
				PREFIX schema: <http://schema.org/>
				PREFIX parl: <http://data.parliament.uk/schema/parl#>
				PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
				CONSTRUCT {
					<#{uri}>
						a schema:Person ;
				   		schema:name ?name ;
						parl:house ?house ;
				    	parl:oralQuestionCount ?oralQuestionCount ;
				   		parl:writtenQuestionCount ?writtenQuestionCount ;
				    	parl:membershipCount ?membershipCount ;
			      		parl:writtenAnswerCount ?writtenAnswerCount ;
		        		parl:voteCount ?voteCount ;
		        		parl:orderPaperItemCount ?orderPaperItemsCount ;
						parl:constituency ?constituency ;
						parl:constituencyLabel ?constituencyLabel .
					?house
						rdfs:label ?label .
				}
				WHERE {
				    SELECT ?name ?house ?label ?constituency ?constituencyLabel (COUNT(DISTINCT ?oralQuestion) AS ?oralQuestionCount) (COUNT(DISTINCT ?writtenQuestion) AS ?writtenQuestionCount) (COUNT(DISTINCT ?writtenAnswer) as ?writtenAnswerCount) (COUNT(DISTINCT ?vote) as ?voteCount) (COUNT(?membership) AS ?membershipCount) (COUNT(?orderPaperItem) AS ?orderPaperItemsCount)
				    WHERE {
				     	?person
							schema:name ?name ;
							parl:house ?house .
						?house
							rdfs:label ?label .
						OPTIONAL {
							?constituency
								parl:member ?person ;
								a parl:Constituency ;
								rdfs:label ?constituencyLabel .
							}
			        	{
			        		?oralQuestion
			        			a parl:OralParliamentaryQuestion ;
			        			parl:member ?person .
			        	}
			        	UNION {
			        	    ?writtenQuestion
			        	        a parl:WrittenParliamentaryQuestion ;
			        	        parl:member ?person .
			        	}
			        	UNION {
			        	    ?writtenAnswer
			        	        a parl:WrittenParliamentaryAnswer ;
			        	        parl:member ?person .
			        	}
			        	UNION {
            				?orderPaperItem
                				a parl:OrderPaperItem ;
                				parl:member ?person .
        				}
			        	UNION {
			        	    ?vote
			      				parl:member ?person ;
			      				parl:division ?division .
			        	}
			        	UNION {
			        	    ?membership
			        	        parl:member ?person ;
			        	        a ?committeeParticipation .
			        	    FILTER (?committeeParticipation = parl:CommitteeMember || ?committeeParticipation = parl:CommitteeChair || ?committeeParticipation = parl:CommitteeAdviser)
			        	}
			    		FILTER(?person = <#{uri}>)
			    	}
			    GROUP BY ?name ?house ?label ?constituency ?constituencyLabel
			}")

		name_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Schema.name,
			:name)
		house_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.house,
			:house)
		constituency_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.constituency,
			:constituency)

		name = result.first_literal(name_pattern)
		house = result.first_object(house_pattern)
		constituency = result.first_object(constituency_pattern)

		house_label_pattern = RDF::Query::Pattern.new(
			house,
			Rdfs.label,
			:label
		)
		label = result.first_literal(house_label_pattern)

		constituency_label_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.constituencyLabel,
			:constituency_label
		)
		constituency_label = result.first_literal(constituency_label_pattern)

		oral_question_count_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.oralQuestionCount,
			:oral_question_count
		)
		written_question_count_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.writtenQuestionCount,
			:written_question_count
		)
		written_answer_count_pattern = RDF::Query::Pattern.new(
			RDF::URI::new(uri),
			Parl.writtenAnswerCount,
			:written_answer_count
		)
		vote_count_pattern = RDF::Query::Pattern.new(
			RDF::URI::new(uri),
			Parl.voteCount,
			:voteCount
		)
		membership_count_pattern = RDF::Query::Pattern.new(
			RDF::URI::new(uri),
			Parl.membershipCount,
			:membershipCount
		)
		order_paper_items_count_pattern = RDF::Query::Pattern.new(
			RDF::URI::new(uri),
			Parl.orderPaperItemCount,
			:orderPaperItemCount
		)

		oral_question_count = result.first_literal(oral_question_count_pattern).to_i
		written_question_count = result.first_literal(written_question_count_pattern).to_i
		written_answer_count = result.first_literal(written_answer_count_pattern).to_i
		vote_count = result.first_literal(vote_count_pattern).to_i
		membership_count = result.first_literal(membership_count_pattern).to_i
		order_paper_item_count = result.first_literal(order_paper_items_count_pattern).to_i

		hierarchy = 
      		{
      		  	:id => self.get_id(uri),
      		  	:name => name.to_s,
      		  	:house => {
      		  		:id => self.get_id(house),
      		  		:label => label.to_s
      		  	},
				:constituency => {
					:id => self.get_id(constituency),
					:label => constituency_label.to_s
				},
				:oral_question_count => oral_question_count,
				:written_question_count => written_question_count,
				:written_answer_count => written_answer_count,
				:vote_count => vote_count,
				:membership_count => membership_count,
				:order_paper_item_count => order_paper_item_count
      		}

		{ :graph => result, :hierarchy => hierarchy }

  	end

  	def self.find_most_active_by_house(house_uri)
  		result = self.query("
  			PREFIX parl: <http://data.parliament.uk/schema/parl#>
      		PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      		PREFIX schema: <http://schema.org/>
      		CONSTRUCT {
      		   ?person 
      		   		a schema:Person ;
      		     	schema:name ?name ;
    			   	parl:count ?count .
      		   <#{house_uri}> 
      		     	rdfs:label ?label .
      		}
      		WHERE { 
    			SELECT ?person ?name ?label (COUNT(?contribution) AS ?count)
    				WHERE {
      		  			<#{house_uri}> 
      		  				rdfs:label ?label .
      		   			?person 
      		   				a schema:Person;
      		   			  	parl:house <#{house_uri}>;
      		   			  	schema:name ?name .
      		  			?contribution 
      		  				parl:member ?person .
      				}
				GROUP BY ?person ?name ?label
				ORDER BY DESC(?count)
				LIMIT 100
			}")

  		person_pattern = RDF::Query::Pattern.new(
  			:person,
  			Schema.name,
  			:name
  		)

  		people = result.query(person_pattern).subjects.map do |subject| 
  			person_name_pattern = RDF::Query::Pattern.new(
  				subject,
  				Schema.name,
  				:name
  			)
  			count_pattern = RDF::Query::Pattern.new(
  				subject,
  				Parl.count,
  				:count
  			)

  			person_name = result.first_literal(person_name_pattern)
  			count = result.first_literal(count_pattern)

  			{
  				:id => self.get_id(subject),
  				:name => person_name.to_s,
  				:count => count.to_i
  			}
  		end

  		house_label_pattern = RDF::Query::Pattern.new(
  			RDF::URI.new(house_uri),
  			Rdfs.label,
  			:house_label
  		)

  		house_label = result.first_literal(house_label_pattern)

  		hierarchy = 
      		{
      			:id => self.get_id(house_uri),
      			:house_label => house_label.to_s,
      			:people => people
      		}

		{ :graph => result, :hierarchy => hierarchy }
  	end

end