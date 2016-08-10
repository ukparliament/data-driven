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
		result = self.query("
			PREFIX schema: <http://schema.org/>
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
						?house
							rdfs:label ?label .
					}
					{
						?writtenQuestion
							a parl:WrittenParliamentaryQuestion ;
							parl:house ?house .
					}
					UNION
					{
						?oralQuestion
							a parl:OralParliamentaryQuestion ;
							parl:house ?house .
					}
					UNION
					{
						?division
							a parl:Division ;
							parl:house ?house .
					}
					UNION
					{
						?person
							a schema:Person ;
							parl:house ?house .
					}
					FILTER(?house = <#{uri}>)
				}
				GROUP BY ?label
			}
		")
		subject_uri = RDF::URI.new(uri)
		
		label = self.get_object(result, subject_uri, Parl.label).to_s
		oral_question_count = self.get_object(result, subject_uri, Parl.oralQuestionCount).to_i
		written_question_count = self.get_object(result, subject_uri, Parl.writtenQuestionCount).to_i
		people_count = self.get_object(result, subject_uri, Parl.peopleCount).to_i
		division_count = self.get_object(result, subject_uri, Parl.divisionCount).to_i

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