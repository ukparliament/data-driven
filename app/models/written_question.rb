class WrittenQuestion < QueryObject

    def self.all
      result = self.client.query("PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                            PREFIX schema: <http://schema.org/>
                            select ?question ?text where { 
                              ?question rdf:type <http://data.parliament.uk/schema/parl#WrittenParliamentaryQuestion>;
                                        schema:text ?text;
                            } limit 100", :content_type => 'application/sparql-results+json')
      self.serialize(result)
    end

    def self.find(uri)
      result = self.client.query("PREFIX schema: <http://schema.org/>
                              PREFIX dcterms: <http://purl.org/dc/terms/>
                              PREFIX parl: <http://data.parliament.uk/schema/parl#>
                              SELECT ?text ?date ?house ?question_member ?house_label ?question_member_name ?answer ?answer_member ?answer_text ?answer_date ?answer_member_name where { 
                              <#{uri}> schema:text ?text;
                                        dcterms:date ?date;
                                        parl:house ?house;
                                        parl:member ?question_member .
                              ?house <http://www.w3.org/2000/01/rdf-schema#label> ?house_label .
                              ?question_member schema:name ?question_member_name .
                              ?answer parl:question <#{uri}>;
                                      schema:text ?answer_text;
                                      dcterms:date ?answer_date;
                                      parl:member ?answer_member .
                              ?answer_member schema:name ?answer_member_name .
                            }")
      result.map do |solution| 
        {
          :id => uri.to_s.split("/").last,
          :text => solution.text.to_s,
          :date => solution.date.to_s.to_datetime,
          :house => {
            :id => solution.house.to_s.split("/").last,
            :label => solution.house_label.to_s
          },
          :tablingMember => {
            :id => solution.question_member.to_s.split("/").last,
            :name => solution.question_member_name.to_s
          },
          :answer => { :id => solution.answer.to_s.split("/").last,
                                  :date => solution.answer_date.to_s.to_datetime,
                                  :answer_text => solution.answer_text.to_s,
                                  :tablingMember => { :id => solution.answer_member, :name => solution.answer_member_name })
                                }
        }
      end.first
    end

 #  	def self.find_by_house(house_uri)
	#     result = @@client.query("PREFIX parl: <http://data.parliament.uk/schema/parl#>
	#                             	    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
	#                             	    select ?uri where { 
	#                             	        ?uri rdf:type parl:WrittenParliamentaryQuestion;
	#                             	          parl:house <#{house_uri}>
	#                             	    } LIMIT 50")
	# end

	# def self.find_by_concept(concept_uri)
	#     WrittenQuestion.find_by_sparql("
	# 	                                PREFIX parl: <http://data.parliament.uk/schema/parl#>
	# 	                                PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
	# 	                                PREFIX dcterms: <http://purl.org/dc/terms/>
	# 	                                select ?uri where { 
	# 	                                    ?uri rdf:type parl:WrittenParliamentaryQuestion;
	# 	                                      dcterms:subject <#{concept_uri}>
	# 	                                }")
	# end

	# def self.find_by_person(person_uri)
 #      	WrittenQuestion.find_by_sparql("
 #                                PREFIX parl: <http://data.parliament.uk/schema/parl#>
 #                                PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
 #                                PREFIX dcterms: <http://purl.org/dc/terms/>
 #                                select ?uri where { 
 #                                    ?uri rdf:type parl:WrittenParliamentaryQuestion;
 #                                      parl:member <#{person_uri}>
 #                                }")
 #  end

  private

  def self.serialize(data, id=nil)
    data.map do |solution| 
      id ||= solution.question
      {
        :id => id.to_s.split("/").last,
        :text => solution.text.to_s
      }
    end
  end

end
