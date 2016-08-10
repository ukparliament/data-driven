class Constituency < QueryObject
  include Vocabulary

  def self.all
    result = self.query('
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX osadm: <http://data.ordnancesurvey.co.uk/ontology/admingeo/>
      CONSTRUCT {
        ?constituency
          rdfs:label ?constituencyLabel ;
          osadm:gssCode ?gssCode ;
      }
      WHERE {
        ?constituency a parl:Constituency ;
          rdfs:label ?constituencyLabel ;
          osadm:gssCode ?gssCode .
      }
    ')

    hierarchy = result.subjects(unique: true).map do |subject|
      constituency_label = self.get_object(result, subject, Rdfs.label).to_s
      gss_code = self.get_object(result, subject, Osadm.gssCode).to_s

      {
          :id => self.get_id(subject),
          :constituency_label => constituency_label,
          :gss_code => gss_code
      }
    end

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find(uri)
    result = self.query("
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX schema: <http://schema.org/>
      PREFIX osadm: <http://data.ordnancesurvey.co.uk/ontology/admingeo/>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      CONSTRUCT{
          ?constituency
              rdfs:label ?label ;
              osadm:gssCode ?gssCode .
          ?member
              schema:name ?member_name .
          ?petition
              dcterms:title ?petitionTitle ;
              parl:numberOfSignatures ?numberOfSignatures .
      }
      WHERE {
        ?constituency
              rdfs:label ?label ;
              osadm:gssCode ?gssCode .
        ?member
              parl:constituency ?constituency ;
              schema:name ?member_name .
        OPTIONAL {
        ?constituencySignature
              parl:constituency ?constituency ;
              rdf:type parl:EPetitionConstituencySignature ;
              parl:numberOfSignatures ?numberOfSignatures ;
              parl:ePetition ?petition .
        ?petition
              dcterms:title ?petitionTitle .
        }
          FILTER ( ?constituency = <#{uri}> )
      }")

    subject_uri = RDF::URI.new(uri)
    constituency_label = self.get_object(result, subject_uri, Rdfs.label).to_s
    gss_code = self.get_object(result, subject_uri, Osadm.gssCode).to_s

    member_pattern = RDF::Query::Pattern.new(
        :member,
        Schema.name,
        :member_name
    )
    members = result.query(member_pattern).subjects.map do |subject|
      member_name = self.get_object(result, subject, Schema.name).to_s
      {
        :id => self.get_id(subject),
        :name => member_name
      }
    end

    petition_pattern = RDF::Query::Pattern.new(
      :peititon,
      Dcterms.title,
      :petition_title
    )
    petitions = result.query(petition_pattern).subjects.map do |subject|
        petition_title = self.get_object(result, subject, Dcterms.title).to_s
        number_of_signatures = self.get_object(result, subject, Parl.numberOfSignatures).to_s
      {
          :id => self.get_id(subject),
          :title => petition_title,
          :number_of_signatures => number_of_signatures
      }
    end

    hierarchy = {
        :id => self.get_id(uri),
        :label => constituency_label,
        :gss_code => gss_code,
        :members => members,
        :petitions => petitions
    }

    { :graph => result, :hierarchy => hierarchy }

  end

end