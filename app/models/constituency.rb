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
              parl:member ?member ;
              schema:name ?member_name .
      }
      WHERE {
        ?constituency rdf:type parl:Constituency ;
              rdfs:label ?constituencyLabel ;
              osadm:gssCode ?gssCode ;
              parl:member ?member .
        ?member
              schema:name ?member_name .
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

      member_pattern = RDF::Query::Pattern.new(
          subject,
          Parl.member,
          :member
      )
      member_id = self.get_id(result.first_object(member_pattern))

      member_name_pattern = RDF::Query::Pattern.new(
          subject,
          Schema.name,
          :member_name
      )
      member_name = result.first_literal(member_name_pattern)

      {
          :id => self.get_id(subject),
          :constituency_label => constituency_label.to_s,
          :gss_code => gss_code.to_s,
          :member => {
              :id => member_id,
              :name => member_name.to_s
          }
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
          <#{uri}>
              rdfs:label ?label ;
              osadm:gssCode ?gssCode ;
              parl:member ?member ;
              schema:name ?member_name .
          ?petition
              dcterms:title ?petitionTitle ;
              parl:numberOfSignatures ?numberOfSignatures .
      }
      WHERE {
        ?constituency
              rdfs:label ?label ;
              parl:member ?member ;
              osadm:gssCode ?gssCode .
          ?member
              schema:name ?member_name .
          ?constituencySignature
              parl:constituency ?constituency ;
              rdf:type parl:EPetitionConstituencySignature ;
              parl:numberOfSignatures ?numberOfSignatures ;
              parl:ePetition ?petition .
          ?petition
              dcterms:title ?petitionTitle .
          FILTER ( ?constituency = <#{uri}> )
      }")

    constituency_label_pattern = RDF::Query::Pattern.new(
      RDF::URI.new(uri),
      Rdfs.label,
      :constituency_label
    )
    constituency_label = result.first_literal(constituency_label_pattern)

    gss_code_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        Osadm.gssCode,
        :gss_code
    )
    gss_code = result.first_literal(gss_code_pattern)

    member_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        Parl.member,
        :member_uri
    )
    member_uri = result.first_object(member_pattern)

    member_name_pattern = RDF::Query::Pattern.new(
        RDF::URI.new(uri),
        Schema.name,
        :member_name
    )
    member_name = result.first_literal(member_name_pattern)

    petitions = result.subjects
      .select{ |subject| subject != RDF::URI.new(uri) }
      .map do |subject|
        petition_uri = subject
        petition_title_pattern = RDF::Query::Pattern.new(
          subject,
          Dcterms.title,
          :petition_title
        )
        petition_title = result.first_literal(petition_title_pattern)
        number_of_signatures_pattern = RDF::Query::Pattern.new(
          subject,
          Parl.numberOfSignatures,
          :number_of_signatures
        )
        number_of_signatures = result.first_literal(number_of_signatures_pattern)
      {
          :id => self.get_id(petition_uri),
          :title => petition_title.to_s,
          :number_of_signatures => number_of_signatures.to_s
      }
    end

    hierarchy = {
        :id => self.get_id(uri),
        :label => constituency_label.to_s,
        :gss_code => gss_code.to_s,
        :member => {
            :id => self.get_id(member_uri),
            :name => member_name.to_s
        },
        :petitions => petitions
    }

    { :graph => result, :hierarchy => hierarchy }

  end

end