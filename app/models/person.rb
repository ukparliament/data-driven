class Person < QueryObject
	include Vocabulary 

  	def self.most_active_people
  			result = self.query('
					PREFIX parl: <http://data.parliament.uk/schema/parl#>
					PREFIX schema: <http://schema.org/>
					CONSTRUCT {
							?person
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

		hierarchy = result.subjects(unique: true).map do |subject| 
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

		{ :graph => result, :hierarchy => hierarchy }

  	end

  	def self.find(uri)
  		result = self.query("
				PREFIX schema: <http://schema.org/>
				PREFIX parl: <http://data.parliament.uk/schema/parl#>
				PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
				CONSTRUCT {
					<#{uri}>
							schema:name ?name ;
						parl:house ?house ;
								parl:oralQuestionCount ?oralQuestionCount ;
								parl:writtenQuestionCount ?writtenQuestionCount ;
								parl:writtenAnswerCount ?writtenAnswerCount .
					?house
						rdfs:label ?label .
				}
				WHERE {
						SELECT ?name ?house ?label (COUNT(DISTINCT ?oralQuestion) AS ?oralQuestionCount) (COUNT(DISTINCT ?writtenQuestion) AS ?writtenQuestionCount) (COUNT(DISTINCT ?writtenAnswer) as ?writtenAnswerCount)
						WHERE {
							<#{uri}>
							schema:name ?name ;
							parl:house ?house .
						?house
							rdfs:label ?label .
								OPTIONAL {
									?oralQuestion
										a parl:OralParliamentaryQuestion ;
										parl:member <#{uri}> .
								}
								OPTIONAL {
										?writtenQuestion
												a parl:WrittenParliamentaryQuestion ;
												parl:member <#{uri}> .
								}
								OPTIONAL {
										?writtenAnswer
												a parl:WrittenParliamentaryAnswer ;
												parl:member <#{uri}> .
								}
						}
						GROUP BY ?name ?house ?label
				}")

		name_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Schema.name,
			:name)
		house_pattern = RDF::Query::Pattern.new(
			RDF::URI.new(uri),
			Parl.house,
			:house)

		name = result.first_literal(name_pattern)
		house = result.first_object(house_pattern)

		house_label_pattern = RDF::Query::Pattern.new(
			house,
			Rdfs.label,
			:label)
		label = result.first_literal(house_label_pattern)

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

		oral_question_count = result.first_literal(oral_question_count_pattern)
		written_question_count = result.first_literal(written_question_count_pattern)
		written_answer_count = result.first_literal(written_answer_count_pattern)

		hierarchy = 
      		{
      		  :id => self.get_id(uri),
      		  :name => name.to_s,
      		  :house => {
      		  	:id => self.get_id(house),
      		  	:label => label.to_s
      		  },
						:oral_question_count => oral_question_count,
						:written_question_count => written_question_count,
						:written_answer_count => written_answer_count
      		}

		{ :graph => result, :hierarchy => hierarchy }

  	end

end