class OralQuestion < QueryObject

  def self.all
    result = self.query("
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX schema: <http://schema.org/>
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      CONSTRUCT {
        ?question schema:text ?text .
      }
      WHERE { 
        ?question 
          rdf:type parl:OralParliamentaryQuestion;
          schema:text ?text;
      }")

    hierarchy = self.convert_to_hash(result)

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find(uri)
    result = self.query("
      PREFIX schema: <http://schema.org/>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      CONSTRUCT {
        <#{uri}> 
          schema:text ?text;
          dcterms:date ?date;
          parl:house ?house;
          parl:member ?member .
        ?house 
          rdf:label ?house_label .
        ?member 
          schema:name ?member_name .
      }
      WHERE {
        <#{uri}> 
          schema:text ?text;
          dcterms:date ?date;
          parl:house ?house;
          parl:member ?member .
        ?house 
          rdf:label ?house_label .
        ?member 
          schema:name ?member_name .
      }
      ")

    hierarchy = result.map do |statement| 
      {
        :id => uri.to_s.split("/").last,
        :text => solution.text.to_s,
        :date => solution.date.to_s.to_datetime,
        :house => Hashit.new({ :id => solution.house.to_s.split("/").last, :label => solution.house_label.to_s }),
        :tablingMember => Hashit.new({ :id => solution.member.to_s.split("/").last, :name => solution.member_name.to_s})
      }
    end.first

    { :graph => result, :hierarchy => hierarchy }
  end

  # def self.find_by_house(house_uri)
  #   result = self.client.query("PREFIX parl: <http://data.parliament.uk/schema/parl#>
  #                           PREFIX schema: <http://schema.org/>
  #                           select ?question ?text where { 
  #                                   ?question rdf:type parl:OralParliamentaryQuestion;
  #                                             parl:house <#{house_uri}>;
  #                                             schema:text ?text .
  #                           }")
  #   self.serialize(result)
  # end

  # def self.find_by_concept(concept_uri)
  #   result = self.client.query("PREFIX parl: <http://data.parliament.uk/schema/parl#>
  #                           PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  #                           PREFIX dcterms: <http://purl.org/dc/terms/>
  #                           PREFIX schema: <http://schema.org/>
  #                           select ?question ?text where { 
  #                                   ?question rdf:type parl:OralParliamentaryQuestion;
  #                                             dcterms:subject <#{concept_uri}>;
  #                                             schema:text ?text .
  #                           }")
  #   self.serialize(result)
  # end

  # def self.find_by_person(person_uri)
  #   result = self.client.query("PREFIX parl: <http://data.parliament.uk/schema/parl#>
  #                           PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  #                           PREFIX schema: <http://schema.org/>
  #                           select ?question ?text where { 
  #                                   ?question rdf:type parl:OralParliamentaryQuestion;
  #                                             parl:member <#{person_uri}>;
  #                                             schema:text ?text .
  #                           }")
  #   self.serialize(result)
  # end

  private

  def self.convert_to_hash(data)
    data.map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :text => statement.object.to_s
      }
    end
  end

end