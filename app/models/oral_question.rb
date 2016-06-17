class OralQuestion < QueryObject
  include Vocabulary

  def self.all
    result = self.query("
      PREFIX schema: <http://schema.org/>
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      CONSTRUCT {
        ?question schema:text ?text .
      }
      WHERE { 
        ?question 
          a parl:OralParliamentaryQuestion;
          schema:text ?text;
      }")

    questions = result.map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :text => statement.object.to_s
      }
    end

    hierarchy = 
    {
      :questions => questions
    }

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find(uri)
    result = self.query("
      PREFIX schema: <http://schema.org/>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      CONSTRUCT {
        <#{uri}>
          schema:text ?text;
          dcterms:date ?date;
          parl:house ?house;
          parl:member ?member;
          dcterms:subject ?concept .
        ?concept
          skos:prefLabel ?concept_label .
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
          parl:member ?member;
          dcterms:subject ?concept .
        ?concept
          skos:prefLabel ?concept_label .
        ?house 
          rdfs:label ?house_label .
        ?member 
          schema:name ?member_label .
      }
      ")

      text_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        Schema.text,
        :text)
      date_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        Dcterms.date,
        :date)
      house_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        Parl.house,
        :house)
      member_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        Parl.member,
        :member)
      
      id = self.get_id(uri)
      text = result.first_literal(text_pattern).to_s
      date = result.first_literal(date_pattern).to_s.to_datetime
      house = result.first_object(house_pattern)
      member = result.first_object(member_pattern)

      house_label_pattern = RDF::Query::Pattern.new(
        house,
        Rdfs.label,
        :house_label)
      member_name_pattern = RDF::Query::Pattern.new(
        member,
        Schema.name,
        :member_name)
      subject_pattern = RDF::Query::Pattern.new(
        :subject,
        Skos.prefLabel,
        :subject_label)

      house_label = result.first_literal(house_label_pattern).to_s
      member_name = result.first_literal(member_name_pattern).to_s
      subject_statements = result.query(subject_pattern)

      subjects = subject_statements.map do |statement|
        {
          :id => self.get_id(statement.subject),
          :label => statement.object.to_s
        }
      end

      hierarchy = 
      {
        :id => id,
        :text => text,
        :date => date,
        :house => { 
            :id => self.get_id(house), 
            :label => house_label
        },
        :member => { 
          :id => self.get_id(member), 
          :name => member_name
        },
        :subjects => subjects
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
      Rdfs.label,
      :house_label)
    questions_pattern = RDF::Query::Pattern.new(
      :question,
      Schema.text,
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

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find_by_concept(concept_uri)
    result = self.query("
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX schema: <http://schema.org/>
      CONSTRUCT {
         ?question 
           schema:text ?text .
         <#{concept_uri}> 
            skos:prefLabel ?label .
      }
      WHERE { 
        <#{concept_uri}> 
          skos:prefLabel ?label .
        ?question 
          dcterms:subject <#{concept_uri}>;
          a parl:OralParliamentaryQuestion;
          schema:text ?text .
         
      }")

    concept_label_pattern = RDF::Query::Pattern.new(
      RDF::URI.new(concept_uri),
      Skos.prefLabel,
      :concept_label)
    questions_pattern = RDF::Query::Pattern.new(
      :question,
      Schema.text,
      :text)


    concept_label = result.first_literal(concept_label_pattern).to_s
    questions = result.query(questions_pattern).map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :text => statement.object.to_s
      }
    end

    hierarchy = {
      :concept_id => self.get_id(concept_uri),
      :concept_label => concept_label,
      :questions => questions
    }

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find_by_person(person_uri)
    result = self.query("
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX schema: <http://schema.org/>
      CONSTRUCT {
         ?question 
           schema:text ?text .
         <#{person_uri}> 
            schema:name ?name .
      }
      WHERE { 
        <#{person_uri}> 
          schema:name ?name .
        ?question 
          parl:member <#{person_uri}>;
          a parl:OralParliamentaryQuestion;
          schema:text ?text .
         
      }")

    person_name_pattern = RDF::Query::Pattern.new(
      RDF::URI.new(person_uri),
      Schema.name,
      :name)
    questions_pattern = RDF::Query::Pattern.new(
      :question,
      Schema.text,
      :text)


    person_name = result.first_literal(person_name_pattern).to_s
    questions = result.query(questions_pattern).map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :text => statement.object.to_s
      }
    end

    hierarchy = {
      :person_id => self.get_id(person_uri),
      :person_name => person_name,
      :questions => questions
    }

    { :graph => result, :hierarchy => hierarchy }
  end
end