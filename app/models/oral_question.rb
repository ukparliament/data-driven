class OralQuestion < QueryObject
  include Vocabulary

  def self.all
    result = self.query('
      PREFIX schema: <http://schema.org/>
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      CONSTRUCT {
        ?question schema:text ?text .
      }
      WHERE {
        ?question
          a parl:OralParliamentaryQuestion;
          schema:text ?text;
      }')

    questions = OralQuestion.map_questions(result)

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
          a skos:Concept ;
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
      subject_uri = RDF::URI.new(uri)

      id = self.get_id(uri)
      text = self.get_object(result, subject_uri, Schema.text).to_s
      date = self.get_object(result, subject_uri, Dcterms.date).to_s.to_datetime
      house = self.get_object(result, subject_uri, Parl.house)
      house_label = self.get_object(result, house, Rdfs.label).to_s
      member = self.get_object(result, subject_uri, Parl.member)
      member_name = self.get_object(result, member, Schema.name).to_s

      subject_pattern = RDF::Query::Pattern.new(
        :subject,
        Skos.prefLabel,
        :subject_label)
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
         ?house 
           rdfs:label ?label .
      }
      WHERE { 
        ?house rdfs:label ?label .

        OPTIONAL {
          ?question 
            rdf:type parl:OralParliamentaryQuestion;
            parl:house ?house;
            schema:text ?text .
        }
        FILTER(?house = <#{house_uri}>)
      }")

    subject_uri = RDF::URI.new(house_uri)
    house_label = self.get_object(result, subject_uri, Rdfs.label).to_s

    questions_pattern = RDF::Query::Pattern.new(
      :question,
      Schema.text,
      :text)
    questions = OralQuestion.map_questions(result.query(questions_pattern))

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
         ?concept
            a skos:Concept ;
            skos:prefLabel ?label .
      }
      WHERE { 
        ?concept skos:prefLabel ?label .

        OPTIONAL {
          ?question 
            dcterms:subject ?concept;
            a parl:OralParliamentaryQuestion;
            schema:text ?text .
        }
        FILTER(?concept = <#{concept_uri}>) 
      }")

    subject_uri = RDF::URI.new(concept_uri)
    concept_label = self.get_object(result, subject_uri, Skos.prefLabel).to_s

    questions_pattern = RDF::Query::Pattern.new(
      :question,
      Schema.text,
      :text)
    questions = OralQuestion.map_questions(result.query(questions_pattern))

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
         ?person
            a schema:Person ;
            schema:name ?name .
      }
      WHERE { 
        ?person schema:name ?name .

        OPTIONAL {
          ?question 
            parl:member ?person;
            a parl:OralParliamentaryQuestion;
            schema:text ?text .
        }
        FILTER(?person = <#{person_uri}>)    
      }")
    subject_uri = RDF::URI.new(person_uri)
    person_name = self.get_object(result, subject_uri, Schema.name).to_s
    
    questions_pattern = RDF::Query::Pattern.new(
      :question,
      Schema.text,
      :text)
    questions = OralQuestion.map_questions(result.query(questions_pattern))

    hierarchy = {
      :person_id => self.get_id(person_uri),
      :person_name => person_name,
      :questions => questions
    }

    { :graph => result, :hierarchy => hierarchy }
  end

end