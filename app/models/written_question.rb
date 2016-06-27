class WrittenQuestion < QueryObject
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
          a parl:WrittenParliamentaryQuestion;
          schema:text ?text;
      }
      LIMIT 100
    ')

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
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      CONSTRUCT {
          <#{uri}> 
              parl:questionText ?text ;
              parl:questionDate ?date ;
              parl:answerText ?answerText ;
              parl:answerDate ?answerDate ;
              dcterms:subject ?concept .
          ?house 
              parl:houseLabel ?houseLabel .
          ?member
              parl:questionMemberName ?memberName .
          ?answeringMember
              parl:answerMemberName ?answeringMemberName .
          ?concept
              skos:prefLabel ?conceptLabel .
      }
      WHERE { 
          <#{uri}>
              schema:text ?text ;
              parl:house ?house ;
              parl:member ?member ;
              dcterms:date ?date ;
              dcterms:subject ?concept .
          ?house 
              rdfs:label ?houseLabel .
          ?member
              schema:name ?memberName .
          ?answer
              parl:question <#{uri}> ;
              parl:member ?answeringMember ;
              schema:text ?answerText ;
              dcterms:date ?answerDate .
          ?answeringMember 
              schema:name ?answeringMemberName .
          ?concept
              skos:prefLabel ?conceptLabel .          
      }      
    ")

    house_pattern = RDF::Query::Pattern.new(
      :house,
      Parl.houseLabel,
      :house)

    question_member_pattern = RDF::Query::Pattern.new(
      :questionMember,
      Parl.questionMemberName,
      :questionMemberName)

    answer_member_pattern = RDF::Query::Pattern.new(
      :answerMember,
      Parl.answerMemberName,
      :answerMemberName)

    question_text_pattern = RDF::Query::Pattern.new(
      RDF::URI.new(uri),
      Parl.questionText,
      :questionText)
    question_date_pattern = RDF::Query::Pattern.new(
      RDF::URI.new(uri),
      Parl.questionDate,
      :questionDate)    

    answer_text_pattern = RDF::Query::Pattern.new(
      RDF::URI.new(uri),
      Parl.answerText,
      :answerText)
    answer_date_pattern = RDF::Query::Pattern.new(
      RDF::URI.new(uri),
      Parl.answerDate,
      :answerDate)  

    subject_pattern = RDF::Query::Pattern.new(
      :subject,
      Skos.prefLabel,
      :subject_label)

    question_id = self.get_id(uri)

    house_statement = result.query(house_pattern)
    house_id = self.get_id(house_statement.first_subject.to_s)
    house_label = house_statement.first_object.to_s

    question_member_statement = result.query(question_member_pattern)
    question_member_id = self.get_id(question_member_statement.first_subject.to_s)
    question_member_name = question_member_statement.first_object.to_s
    question_text = result.first_literal(question_text_pattern).to_s
    question_date = result.first_literal(question_date_pattern).to_s.to_datetime

    answer_member_statement = result.query(answer_member_pattern)
    answer_member_id = self.get_id(answer_member_statement.first_subject.to_s)
    answer_member_name = answer_member_statement.first_object.to_s
    answer_text = result.first_literal(answer_text_pattern).to_s
    answer_date = result.first_literal(answer_date_pattern).to_s.to_datetime

    subject_statements = result.query(subject_pattern)

    subjects = subject_statements.map do |statement|
      {
        :id => self.get_id(statement.subject.to_s),
        :label => statement.object.to_s
      }
    end

    hierarchy = {
      :id => question_id,
      :house => {
        :id => house_id,
        :label => house_label
      },
      :question_member => {
        :id => question_member_id,
        :name => question_member_name
      },
      :date => question_date,
      :text => question_text,
      :answer => {
        :date => answer_date,
        :text => answer_text,
        :member => {
          :id => answer_member_id,
          :name => answer_member_name        
        }
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
            rdf:type parl:WrittenParliamentaryQuestion;
            parl:house ?house;
            schema:text ?text .
        }
        FILTER(?house = <#{house_uri}>)
      }
      LIMIT 200")

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
         ?concept 
            skos:prefLabel ?label .
      }
      WHERE { 
        ?concept skos:prefLabel ?label .

        OPTIONAL {
          ?question 
            dcterms:subject ?concept;
            a parl:WrittenParliamentaryQuestion;
            schema:text ?text .
        }
        FILTER(?concept = <#{concept_uri}>)    
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
         ?person 
            schema:name ?name .
      }
      WHERE { 
        ?person schema:name ?name .
        
        OPTIONAL {
          ?question 
            parl:member ?person;
            a parl:WrittenParliamentaryQuestion;
            schema:text ?text .
        }
        FILTER(?person = <#{person_uri}>)      
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
