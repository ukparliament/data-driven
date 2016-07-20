class Constituency < QueryObject
  include Vocabulary

  def self.all
    result = self.query('
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX osadm: <http://data.ordnancesurvey.co.uk/ontology/admingeo/>
      PREFIX schema: <http://schema.org/>
      CONSTRUCT {
          ?constituency
              rdfs:label ?constituencyLabel ;
              osadm:gssCode ?gssCode ;
      }
      WHERE {
        ?constituency rdf:type parl:Constituency ;
              rdfs:label ?constituencyLabel ;
              osadm:gssCode ?gssCode .
      }
    ')

    constituencies = result.subjects(unique: true).map do |subject|
      constituency_label_pattern = RDF::Query::Pattern.new(
          subject,
          Rdfs.label,
          :constituency_label
      )
      constituency_label = result.first_literal(constituency_label_pattern)

      gss_code_pattern = RDF::Query::Pattern.new(
          subject,
          Osadm.gssCode,
          :gss_code
      )
      gss_code = result.first_literal(gss_code_pattern)

      {
          :id => self.get_id(subject),
          :constituency_label => constituency_label.to_s,
          :gss_code => gss_code.to_s
      }
    end

    hierarchy = {
        :constituencies => constituencies
    }

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find(uri)
    result = self.query("PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
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

    constituency_label_pattern = RDF::Query::Pattern.new(
      RDF::URI.new(uri),
      Rdfs.label,
      :constituency_label
    )
    constituency_label = result.first_literal(constituency_label_pattern).to_s

    gss_code_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        Osadm.gssCode,
        :gss_code
    )
    gss_code = result.first_literal(gss_code_pattern).to_s

    member_pattern = RDF::Query::Pattern.new(
        :member,
        Schema.name,
        :member_name
    )

    members = result.query(member_pattern).subjects.map do |subject|
      member_name_pattern = RDF::Query::Pattern.new(
        subject,
        Schema.name,
        :member_name
      )
      member_name = result.first_literal(member_name_pattern).to_s
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
        petition_title_pattern = RDF::Query::Pattern.new(
          subject,
          Dcterms.title,
          :petition_title
        )
        petition_title = result.first_literal(petition_title_pattern).to_s
        number_of_signatures_pattern = RDF::Query::Pattern.new(
          subject,
          Parl.numberOfSignatures,
          :number_of_signatures
        )
        number_of_signatures = result.first_literal(number_of_signatures_pattern).to_s
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