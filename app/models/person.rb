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
			name = self.get_object(result, subject, Schema.name).to_s
			count = self.get_object(result, subject, Parl.count).to_i
			{
				:id => self.get_id(subject),
				:name => name,
				:count => count
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

  		subject_uri = RDF::URI.new(uri)
		name = self.get_object(result, subject_uri, Schema.name).to_s
		house = self.get_object(result, subject_uri, Parl.house)
		label = self.get_object(result, house, Rdfs.label).to_s
		constituency = self.get_object(result, subject_uri, Parl.constituency)
		constituency_label = self.get_object(result, constituency, Parl.constituencyLabel).to_s

		oral_question_count = self.get_object(result, subject_uri, Parl.oralQuestionCount).to_i
		written_question_count = self.get_object(result, subject_uri, Parl.writtenQuestionCount).to_i
		written_answer_count = self.get_object(result, subject_uri, Parl.writtenAnswerCount).to_i
		vote_count = self.get_object(result, subject_uri, Parl.voteCount).to_i
		membership_count = self.get_object(result, subject_uri, Parl.membershipCount).to_i
		order_paper_item_count = self.get_object(result, subject_uri, Parl.orderPaperItemCount).to_i

		hierarchy = 
      		{
      		  	:id => self.get_id(uri),
      		  	:name => name,
      		  	:house => {
      		  		:id => self.get_id(house),
      		  		:label => label
      		  	},
				:constituency => {
					:id => self.get_id(constituency),
					:label => constituency_label
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
  			person_name = self.get_object(result, subject, Schema.name).to_s
  			count = self.get_object(result, subject, Parl.count).to_i

  			{
  				:id => self.get_id(subject),
  				:name => person_name,
  				:count => count
  			}
  		end

  		subject_uri = RDF::URI.new(house_uri)
  		house_label = self.get_object(result, subject_uri, Rdfs.label).to_s
  		
  		hierarchy = 
      		{
      			:id => self.get_id(house_uri),
      			:house_label => house_label,
      			:people => people
      		}

		{ :graph => result, :hierarchy => hierarchy }
  	end

end