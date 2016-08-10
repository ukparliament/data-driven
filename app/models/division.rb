class Division < QueryObject
  include Vocabulary

  def self.all
      result = self.query("
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      CONSTRUCT {
        ?division dcterms:title ?title .
      }
      WHERE { 
        ?division
          a parl:Division ;
          dcterms:title ?title .
      }")

    divisions = result.map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :title => statement.object.to_s
      }
    end

    hierarchy = {
      :divisions => divisions
    }

    { :graph => result, :hierarchy => hierarchy }
  end

 def self.find(uri)
    result = self.query("
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      CONSTRUCT {
        <#{uri}> 
          dcterms:title ?title ;
          dcterms:description ?description ;
          dcterms:date ?date ;
          parl:house ?house .
        ?house
          rdfs:label ?house_label .
      }
      WHERE { 
        <#{uri}> 
          dcterms:title ?title ;
          dcterms:description ?description ;
          dcterms:date ?date ;
          parl:house ?house .
        ?house
          rdfs:label ?house_label .
      }")

      subject_uri = RDF::URI.new(uri)

      title = self.get_object(result, subject_uri, Dcterms.title).to_s
      description = self.get_object(result, subject_uri, Dcterms.description).to_s
      date = self.get_object(result, subject_uri, Dcterms.date).to_s.to_datetime
      house = self.get_object(result, subject_uri, Parl.house)
      house_label = self.get_object(result, house, Rdfs.label).to_s

      hierarchy = result.map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :title => title,
        :description => description,
        :date => date,
        :house => {
          :id => self.get_id(house),
          :label => house_label
        }
      }
    end.first

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find_by_house(house_uri)
    result = self.query("
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX dcterms: <http://purl.org/dc/terms/>     
      CONSTRUCT {
         ?division 
           dcterms:title ?title .
         ?house
           rdfs:label ?label .
      }
      WHERE { 
        ?house rdfs:label ?label .

        OPTIONAL {
          ?division 
            a parl:Division;
            parl:house ?house;
            dcterms:title ?title .
        }

        FILTER(?house = <#{house_uri}>)
      }")

    house_uri = RDF::URI.new(house_uri)
    house_label = self.get_object(result, house_uri, Rdfs.label).to_s

    divisions_pattern = RDF::Query::Pattern.new(
      :division,
      Dcterms.title,
      :title)
    divisions = result.query(divisions_pattern).map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :title => statement.object.to_s
      }
    end

    hierarchy = {
      :id => self.get_id(house_uri),
      :house_label => house_label,
      :divisions => divisions
    }

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find_by_concept(concept_uri)
    result = self.query("
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX dcterms: <http://purl.org/dc/terms/>     

      CONSTRUCT {
          ?concept
              a skos:Concept ;
              skos:prefLabel ?label .
          ?division 
              dcterms:title ?title .
      }
      WHERE { 
          ?concept skos:prefLabel ?label .

          OPTIONAL{
              ?division 
                  a parl:Division;
                  dcterms:subject ?concept ;
                  dcterms:title ?title .
          }
          
          FILTER(?concept = <#{concept_uri}>)
      }")

    concept_uri = RDF::URI.new(concept_uri)
    concept_label = self.get_object(result, concept_uri, Skos.prefLabel).to_s

    divisions_pattern = RDF::Query::Pattern.new(
      :division,
      Dcterms.title,
      :title)    
    divisions = result.query(divisions_pattern).map do |statement| 
      {
        :id => self.get_id(statement.subject),
        :title => statement.object.to_s
      }
    end

    hierarchy = {
      :id => self.get_id(concept_uri),
      :concept_label => concept_label,
      :divisions => divisions
    }

    { :graph => result, :hierarchy => hierarchy }
  end

end