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
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      CONSTRUCT {
        <#{uri}>
          schema:text ?text;
          dcterms:date ?date;
          parl:house ?house;
          parl:member ?member .
        ?house 
          rdfs:label ?house_label .
        ?member 
          schema:name ?member_label .
      }
      WHERE {
        <#{uri}> 
          schema:text ?text;
          dcterms:date ?date;
          parl:house ?house;
          parl:member ?member .
        ?house 
          rdfs:label ?house_label .
        ?member 
          schema:name ?member_label .
      }
      ")

      text_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        RDF::URI.new('http://schema.org/text'),
        :text)
      date_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        RDF::URI.new('http://purl.org/dc/terms/date'),
        :date)
      house_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        RDF::URI.new('http://data.parliament.uk/schema/parl#house'),
        :house)
      member_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        RDF::URI.new('http://data.parliament.uk/schema/parl#member'),
        :member)
      
      id = self.get_id(uri)
      text = result.first_literal(text_pattern).to_s
      date = result.first_literal(date_pattern).to_s.to_datetime
      house = result.first_object(house_pattern)
      member = result.first_object(member_pattern)

      house_label_pattern = RDF::Query::Pattern.new(
        house,
        RDF::URI.new('http://www.w3.org/2000/01/rdf-schema#label'),
        :house_label)
      member_name_pattern = RDF::Query::Pattern.new(
        member,
        RDF::URI.new('http://schema.org/name'),
        :member_name)

      house_label = result.first_literal(house_label_pattern).to_s
      member_name = result.first_literal(member_name_pattern).to_s

      hierarchy = 
      {
        :id => id,
        :text => text,
        :date => date,
        :house => { 
            :id => self.get_id(house), 
            :label => house_label },
        :member => { 
          :id => self.get_id(member), 
          :name => member_name}
      }

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find_by_house(house_uri)
    result = self.query("
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX schema: <http://schema.org/>
      CONSTRUCT {
         ?question 
           schema:text ?text .
         <#{house_uri}> 
           rdfs:label ?label .
      }
      WHERE { 
         ?question 
           rdf:type parl:OralParliamentaryQuestion;
           parl:house <#{house_uri}>;
           schema:text ?text .
         <#{house_uri}> rdfs:label ?label .
      }")

    house_label_pattern = RDF::Query::Pattern.new(
      RDF::URI.new(house_uri),
      RDF::URI.new('http://www.w3.org/2000/01/rdf-schema#label'),
      :house_label)
    questions_pattern = RDF::Query::Pattern.new(
      :question,
      RDF::URI.new('http://schema.org/text'),
      :text)


    house_label = result.first_literal(house_label_pattern).to_s
    questions = result.query(questions_pattern).map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :text => statement.object.to_s
      }
    end

    hierarchy = {
      :house_id => self.get_id(house_uri),
      :house_label => house_label,
      :questions => questions
    }

    p hierarchy
    { :graph => result, :hierarchy => hierarchy }
  end

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