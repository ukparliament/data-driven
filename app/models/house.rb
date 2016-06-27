class House < QueryObject
  include Vocabulary

	def self.all
		result = self.query('
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
      		PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			CONSTRUCT {
				?house rdfs:label ?label .
			}
			WHERE {
				?house
					a parl:House ;
					rdfs:label ?label .
			}')

		hierarchy = self.convert_to_hash(result)

		{ :graph => result, :hierarchy => hierarchy }
	end

	def self.find(uri)
		result = self.query("PREFIX schema: <http://schema.org/>
			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			CONSTRUCT {
				<#{uri}>
						parl:label ?label ;
						parl:writtenQuestionCount ?writtenQuestionCount ;
						parl:oralQuestionCount ?oralQuestionCount ;
						parl:divisionCount ?divisionCount ;
						parl:peopleCount ?peopleCount .
			}
			WHERE {
					SELECT ?label (COUNT(DISTINCT ?oralQuestion) AS ?oralQuestionCount) (COUNT(DISTINCT ?writtenQuestion) AS ?writtenQuestionCount) (COUNT(DISTINCT ?division) AS ?divisionCount) (COUNT(DISTINCT ?person) AS ?peopleCount)
					WHERE {
							{
									<#{uri}>
										rdfs:label ?label .
							}
							{
									?writtenQuestion
										a parl:WrittenParliamentaryQuestion ;
										parl:house <#{uri}> .
							}
								UNION {
									?oralQuestion
										a parl:OralParliamentaryQuestion ;
										parl:house <#{uri}> .
							}
								UNION {
									?division
										a parl:Division ;
										parl:house <#{uri}> .
							}
								UNION {
									?person
										a schema:Person ;
										parl:house <#{uri}> .
							}
					}
					GROUP BY ?label
			}")

		house_label_pattern = RDF::Query::Pattern.new(
				RDF::URI.new(uri),
				Rdfs.label,
				:label)
		label = result.first_literal(house_label_pattern).to_s

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
		division_count_pattern = RDF::Query::Pattern.new(
				RDF::URI::new(uri),
				Parl.divisionCount,
				:division_count
		)
		people_count_pattern = RDF::Query::Pattern.new(
				RDF::URI::new(uri),
				Parl.peopleCount,
				:people_count
		)

		oral_question_count = result.first_literal(oral_question_count_pattern)
		written_question_count = result.first_literal(written_question_count_pattern)
		people_count = result.first_literal(people_count_pattern)
		division_count = result.first_literal(division_count_pattern)

		hierarchy =
				{
						:id => self.get_id(uri),
						:label => label,
						:oral_question_count => oral_question_count,
						:written_question_count => written_question_count,
						:people_count => people_count,
						:division_count => division_count
				}

		{ :graph => result, :hierarchy => hierarchy }
	end

	private

	def self.convert_to_hash(data)
		data.map do |statement| 
			{
				:id => self.get_id(statement.subject),
				:label => statement.object.to_s
			}
		end
	end

end