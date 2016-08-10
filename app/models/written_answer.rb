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

		{ :id => self.get_id(question) }
 	end

 	def self.find_by_person(person_uri)
 		result = self.query("
 			PREFIX parl: <http://data.parliament.uk/schema/parl#>
 			PREFIX schema: <http://schema.org/>
			CONSTRUCT {
    		?answer 
        	parl:member ?person ;
        	schema:text ?text .
    		?person
          a schema:Person ;
        	schema:name ?name .
			}
			WHERE { 
        ?person schema:name ?name .

        OPTIONAL {
          ?answer 
              a parl:WrittenParliamentaryAnswer ;
              parl:member ?person ;
              schema:text ?text .
        }
				FILTER(?person = <#{person_uri}>)

		}")

 		written_answers_pattern = RDF::Query::Pattern.new(
 			:answer,
 			Schema.text,
 			:text)

 		written_answers = result.query(written_answers_pattern).subjects.map do |subject|
 			text = self.get_object(result, subject, Schema.text).to_s

 			{
 				:id => self.get_id(subject),
 				:text => text
 			}
 		end

 		person_name = self.get_object(result, RDF::URI.new(person_uri), Schema.name)

		hierarchy = 
      		{
      		  :id => self.get_id(person_uri),
      		  :name => person_name.to_s,
      		  :written_answers => written_answers
      		}

    	{ :graph => result, :hierarchy => hierarchy }
 	end
end