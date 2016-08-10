class WrittenQuestion < QueryObject
  include Vocabulary

  def self.all
    result = self.query('
      PREFIX schema: <http://schema.org/>
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      CONSTRUCT {
        ?question 
          schema:text ?text ;
      }
      WHERE {
        ?question
          a parl:WrittenParliamentaryQuestion;
          schema:text ?text;
      }
      LIMIT 100
    ')

    questions = self.map_questions(result)

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
        ?question 
          parl:questionText ?text ;
          parl:questionDate ?date ;
          parl:house ?house ;
          parl:member ?member ;
          parl:answer ?answer .
        ?house 
          parl:houseLabel ?houseLabel .
        ?member
          parl:questionMemberName ?memberName .
        ?answer
          parl:answerText ?answerText ;
          parl:answerDate ?answerDate ;
          parl:answeringMember ?answeringMember .
        ?answeringMember
          parl:answerMemberName ?answeringMemberName .
        ?concept
          skos:prefLabel ?conceptLabel .
      }
      WHERE { 
        ?question
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
          parl:question ?question ;
          parl:member ?answeringMember ;
          schema:text ?answerText ;
          dcterms:date ?answerDate .
        ?answeringMember 
          schema:name ?answeringMemberName .
        ?concept
          skos:prefLabel ?conceptLabel .  

        FILTER(?question = <#{uri}>)
      } 
    ")

    question_uri = RDF::URI.new(uri)
    house = self.get_object(result, question_uri, Parl.house)
    house_label = self.get_object(result, house, Parl.houseLabel).to_s
    question_member = self.get_object(result, question_uri, Parl.member)
    question_member_name = self.get_object(result, question_member, Parl.questionMemberName).to_s
    question_date = self.get_object(result, question_uri, Parl.questionDate).to_s.to_datetime
    question_text = self.get_object(result, question_uri, Parl.questionText).to_s
    answer = self.get_object(result, question_uri, Parl.answer)
    answer_date = self.get_object(result, answer, Parl.answerDate).to_s.to_datetime
    answer_text = self.get_object(result, answer, Parl.answerText).to_s
    answer_member = self.get_object(result, answer, Parl.answeringMember)
    answer_member_name = self.get_object(result, answer_member, Parl.answerMemberName).to_s 

    subject_pattern = RDF::Query::Pattern.new(
      :subject,
      Skos.prefLabel,
      :subject_label)

    subjects = result.query(subject_pattern).map do |statement|
      {
        :id => self.get_id(statement.subject),
        :label => statement.object.to_s
      }
    end

    hierarchy = {
      :id => self.get_id(uri),
      :house => {
        :id => self.get_id(house),
        :label => house_label
      },
      :question_member => {
        :id => self.get_id(question_member),
        :name => question_member_name
      },
      :date => question_date,
      :text => question_text,
      :answer => {
        :id => self.get_id(answer),
        :date => answer_date,
        :text => answer_text,
        :member => {
          :id => self.get_id(answer_member),
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

    house_label = self.get_object(result, RDF::URI.new(house_uri), Rdfs.label).to_s

    questions_pattern = RDF::Query::Pattern.new(
      :question,
      Schema.text,
      :text)

    questions = self.map_questions(result.query(questions_pattern))

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
            a parl:WrittenParliamentaryQuestion;
            schema:text ?text .
        }
        FILTER(?concept = <#{concept_uri}>)    
      }")

    concept_label = self.get_object(result, RDF::URI.new(concept_uri), Skos.prefLabel).to_s

    questions_pattern = RDF::Query::Pattern.new(
      :question,
      Schema.text,
      :text)

    questions = self.map_questions(result.query(questions_pattern))

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
            a parl:WrittenParliamentaryQuestion;
            schema:text ?text .
        }
        FILTER(?person = <#{person_uri}>)      
      }")

    person_name = self.get_object(result, RDF::URI.new(person_uri), Schema.name).to_s

    questions_pattern = RDF::Query::Pattern.new(
      :question,
      Schema.text,
      :text)

    questions = self.map_questions(result.query(questions_pattern))

    hierarchy = {
      :person_id => self.get_id(person_uri),
      :person_name => person_name,
      :questions => questions
    }

    { :graph => result, :hierarchy => hierarchy }
  end

end
