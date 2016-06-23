class WrittenAnswer < QueryObject
	include Vocabulary

 	def self.find_question(uri)
 		result = self.query("
 			PREFIX parl: <http://data.parliament.uk/schema/parl#>
			CONSTRUCT {
    			<#{uri}> parl:question ?question .
			}
			WHERE { 
				<#{uri}> parl:question ?question .
		}")

 		question_pattern = RDF::Query::Pattern.new(
 			RDF::URI.new(uri),
 			Parl.question,
 			:question)

		question = result.first_object(question_pattern)

		p question

		{ :id => self.get_id(question) }
 	end
end